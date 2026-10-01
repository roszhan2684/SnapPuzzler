//
//  GameViewModel.swift
//  SnapPuzzler
//
//  Created by ROSZHAN RAJ on 14/03/26.
//

import Foundation
import Combine
import AVFoundation
import CoreGraphics
import UIKit

final class GameViewModel: ObservableObject {
    @Published var title: String = "SNAPPUZZLER"
    @Published var statusMessage: String = "Checking camera permission..."
    @Published var currentMode: GameMode = .threeByThree
    @Published var isGameReady: Bool = false
    @Published var permissionDenied: Bool = false

    @Published var handPoints: [HandPoint] = []
    @Published var handConnections: [HandConnection] = []
    @Published var handDetected: Bool = false

    @Published var isPinching: Bool = false
    @Published var pinchDistance: CGFloat = 0
    @Published var pinchPoint: CGPoint = .zero

    @Published var frameRect: FrameRect = .hidden
    @Published var lockedFrameRect: FrameRect = .hidden
    @Published var hasLockedFrame: Bool = false

    @Published var capturedPuzzleImage: CapturedPuzzleImage?
    @Published var puzzleBoard: PuzzleBoard?
    @Published var selectedTile: PuzzleTile?

    @Published var elapsedTime: TimeInterval = 0
    @Published var moveCount: Int = 0
    @Published var isUsingFrontHandTracking: Bool = false

    private var pinchAnchorPoint: CGPoint?
    private var lastDragPoint: CGPoint?

    let cameraService: CameraService
    let handCameraService: CameraService
    let handTrackingService: HandTrackingService
    let frameCaptureService: FrameCaptureService
    let previewLayerStore: PreviewLayerStore
    let puzzleImageSlicerService: PuzzleImageSlicerService
    let scoreStorageService: ScoreStorageService

    private var cancellables = Set<AnyCancellable>()
    private var gameTimer: Timer?
    private var timerStartDate: Date?
    private let handTrackingQueue = DispatchQueue(label: "snappuzzler.handtracking.queue")

    init(
        cameraService: CameraService = CameraService(),
        handCameraService: CameraService = CameraService(),
        handTrackingService: HandTrackingService = HandTrackingService(),
        frameCaptureService: FrameCaptureService = FrameCaptureService(),
        previewLayerStore: PreviewLayerStore = PreviewLayerStore(),
        puzzleImageSlicerService: PuzzleImageSlicerService = PuzzleImageSlicerService(),
        scoreStorageService: ScoreStorageService = ScoreStorageService()
    ) {
        self.cameraService = cameraService
        self.handCameraService = handCameraService
        self.handTrackingService = handTrackingService
        self.frameCaptureService = frameCaptureService
        self.previewLayerStore = previewLayerStore
        self.puzzleImageSlicerService = puzzleImageSlicerService
        self.scoreStorageService = scoreStorageService

        bindCameraService()
        bindHandTrackingService()
    }

    private func bindCameraService() {
        cameraService.$permissionGranted
            .receive(on: DispatchQueue.main)
            .sink { [weak self] granted in
                guard let self else { return }

                if granted {
                    self.permissionDenied = false
                    self.statusMessage = "Camera ready. Looking for your hand..."
                    self.isGameReady = true
                    self.updateHandTrackingSource(for: self.cameraService.currentCameraPosition)
                } else {
                    self.permissionDenied = true
                    self.statusMessage = "Camera permission is required to play SnapPuzzler."
                    self.isGameReady = false
                    self.handCameraService.stopSession()
                }
            }
            .store(in: &cancellables)

        cameraService.$isSessionRunning
            .receive(on: DispatchQueue.main)
            .sink { [weak self] running in
                guard let self else { return }
                if running && !self.handDetected && self.capturedPuzzleImage == nil {
                    self.statusMessage = "Show your full hand to begin."
                }
            }
            .store(in: &cancellables)

        cameraService.$currentCameraPosition
            .receive(on: DispatchQueue.main)
            .sink { [weak self] position in
                guard let self else { return }
                self.updateHandTrackingSource(for: position)
            }
            .store(in: &cancellables)
    }

    private func updateHandTrackingSource(for position: AVCaptureDevice.Position) {
        guard cameraService.permissionGranted else { return }

        if position == .back {
            isUsingFrontHandTracking = true
            cameraService.clearVideoOutputDelegate()
            handCameraService.setCameraPosition(.front)
            handCameraService.setVideoOutputDelegate(handTrackingService, queue: handTrackingQueue)
            handTrackingService.updateCameraPosition(.front)
        } else {
            isUsingFrontHandTracking = false
            handCameraService.clearVideoOutputDelegate()
            handCameraService.stopSession()
            cameraService.setVideoOutputDelegate(handTrackingService, queue: handTrackingQueue)
            handTrackingService.updateCameraPosition(.front)
        }
    }

    private func bindHandTrackingService() {
        handTrackingService.$points
            .receive(on: DispatchQueue.main)
            .sink { [weak self] points in
                guard let self else { return }
                self.handPoints = points
                if self.capturedPuzzleImage == nil {
                    self.updatePinchAndFrame(using: points)
                }
            }
            .store(in: &cancellables)

        handTrackingService.$connections
            .receive(on: DispatchQueue.main)
            .assign(to: &$handConnections)

        handTrackingService.$handDetected
            .receive(on: DispatchQueue.main)
            .sink { [weak self] detected in
                guard let self else { return }
                self.handDetected = detected

                if self.capturedPuzzleImage != nil { return }

                if !detected && !self.isPinching && !self.hasLockedFrame {
                    self.statusMessage = "Show your full hand to begin."
                } else if detected && !self.isPinching && !self.hasLockedFrame {
                    self.statusMessage = "Pinch thumb and index together to start framing."
                }
            }
            .store(in: &cancellables)
    }

    private func updatePinchAndFrame(using points: [HandPoint]) {
        guard
            let thumbTip = points.first(where: { $0.name == "thumbTip" }),
            let indexTip = points.first(where: { $0.name == "indexTip" })
        else {
            handlePinchReleased()
            return
        }

        let dx = thumbTip.point.x - indexTip.point.x
        let dy = thumbTip.point.y - indexTip.point.y
        let distance = sqrt(dx * dx + dy * dy)
        pinchDistance = distance

        let midpoint = CGPoint(
            x: (thumbTip.point.x + indexTip.point.x) / 2,
            y: (thumbTip.point.y + indexTip.point.y) / 2
        )
        pinchPoint = midpoint

        let pinchStartThreshold: CGFloat = 0.028
        let pinchReleaseThreshold: CGFloat = 0.05

        if !isPinching {
            if distance < pinchStartThreshold {
                beginPinch(at: midpoint)
            }
        } else {
            if distance > pinchReleaseThreshold {
                handlePinchReleased()
            } else {
                updateDraggingFrame(to: midpoint)
            }
        }
    }

    private func beginPinch(at point: CGPoint) {
        isPinching = true
        hasLockedFrame = false
        lockedFrameRect = .hidden
        capturedPuzzleImage = nil
        puzzleBoard = nil
        selectedTile = nil
        resetGameProgress()

        let clamped = clampPoint(point)
        pinchAnchorPoint = clamped
        lastDragPoint = clamped

        frameRect = FrameRect.squareFromPoints(clamped, clamped)
        statusMessage = "Pinch started. Drag to grow the square."
    }

    private func updateDraggingFrame(to point: CGPoint) {
        guard let anchor = pinchAnchorPoint else { return }

        let clamped = clampPoint(point)
        lastDragPoint = clamped

        let square = FrameRect.squareFromPoints(anchor, clamped)

        let minSide: CGFloat = 0.05
        if square.size.width >= minSide && square.size.height >= minSide {
            frameRect = clampSquareFrame(square)
        }

        statusMessage = "Keep dragging. Release to snap."
    }

    private func clampSquareFrame(_ rect: FrameRect) -> FrameRect {
        let width = rect.size.width
        let height = rect.size.height

        guard width > 0, height > 0 else { return .hidden }

        let halfW = width / 2
        let halfH = height / 2

        let clampedCenter = CGPoint(
            x: min(max(rect.center.x, halfW), 1 - halfW),
            y: min(max(rect.center.y, halfH), 1 - halfH)
        )

        return FrameRect(
            center: clampedCenter,
            size: CGSize(width: width, height: height),
            isVisible: true
        )
    }

    private func handlePinchReleased() {
        if isPinching {
            isPinching = false

            if frameRect.isVisible, frameRect.size.width > 0.05, frameRect.size.height > 0.05 {
                lockedFrameRect = frameRect
                hasLockedFrame = true
                captureLockedFrame()
            } else {
                frameRect = .hidden
                lockedFrameRect = .hidden
                hasLockedFrame = false
                statusMessage = handDetected
                    ? "Pinch thumb and index together to start framing."
                    : "Show your full hand to begin."
            }

            pinchAnchorPoint = nil
            lastDragPoint = nil
        } else if !hasLockedFrame {
            frameRect = .hidden
        }
    }

    private func captureLockedFrame() {
        guard
            let sampleBuffer = cameraService.latestSampleBuffer(),
            let portraitImage = frameCaptureService.portraitImageFromSampleBuffer(
                sampleBuffer,
                cameraPosition: cameraService.currentCameraPosition
            ),
            let visiblePreviewRect = previewLayerStore.normalizedVisiblePreviewRect(),
            let visiblePreviewImage = frameCaptureService.cropImage(
                portraitImage,
                normalizedRect: visiblePreviewRect
            )
        else {
            statusMessage = "Snap failed. Try again."
            return
        }

        let frameNormalizedRect = CGRect(
            x: lockedFrameRect.center.x - lockedFrameRect.size.width / 2,
            y: lockedFrameRect.center.y - lockedFrameRect.size.height / 2,
            width: lockedFrameRect.size.width,
            height: lockedFrameRect.size.height
        )

        guard let selectedRegionImage = frameCaptureService.cropImage(
            visiblePreviewImage,
            normalizedRect: frameNormalizedRect
        ) else {
            statusMessage = "Could not crop selected frame."
            return
        }

        capturedPuzzleImage = CapturedPuzzleImage(
            visiblePreviewImage: visiblePreviewImage,
            selectedRegionImage: selectedRegionImage,
            frameRect: lockedFrameRect
        )

        buildPuzzleBoard(from: selectedRegionImage)
    }

    private func buildPuzzleBoard(from image: UIImage) {
        guard let board = puzzleImageSlicerService.makePuzzleBoard(
            from: image,
            gridSize: currentMode.rawValue
        ) else {
            statusMessage = "Could not create puzzle."
            return
        }

        puzzleBoard = board
        selectedTile = nil
        resetGameProgress()
        startTimer()
        statusMessage = "Puzzle ready. Tap two tiles to swap."
    }

    func selectTile(_ tile: PuzzleTile) {
        guard var board = puzzleBoard else { return }

        if let selectedTile {
            if selectedTile.id == tile.id {
                self.selectedTile = nil
                return
            }

            board.swapTiles(first: selectedTile, second: tile)
            puzzleBoard = board
            self.selectedTile = nil
            moveCount += 1

            if board.isSolved {
                handlePuzzleSolved()
            } else {
                statusMessage = "Good move. Keep going."
            }
        } else {
            self.selectedTile = tile
            statusMessage = "Tile selected. Tap another tile to swap."
        }
    }

    private func handlePuzzleSolved() {
        stopTimer()
        statusMessage = "Puzzle solved!"
        scoreStorageService.updateBestScore(
            gridSize: currentMode.rawValue,
            newTime: elapsedTime,
            newMoves: moveCount
        )
    }

    func playAgain() {
        guard let capturedPuzzleImage else { return }
        buildPuzzleBoard(from: capturedPuzzleImage.selectedRegionImage)
    }

    private func resetGameProgress() {
        stopTimer()
        elapsedTime = 0
        moveCount = 0
    }

    private func startTimer() {
        guard gameTimer == nil else { return }
        timerStartDate = Date()
        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateElapsedTime()
        }
        timer.tolerance = 0.05
        gameTimer = timer
    }

    private func stopTimer() {
        updateElapsedTime()
        gameTimer?.invalidate()
        gameTimer = nil
        timerStartDate = nil
    }

    private func updateElapsedTime() {
        guard let timerStartDate else { return }
        elapsedTime = Date().timeIntervalSince(timerStartDate)
    }

    private func clampPoint(_ point: CGPoint) -> CGPoint {
        CGPoint(
            x: min(max(point.x, 0.02), 0.98),
            y: min(max(point.y, 0.02), 0.98)
        )
    }

    var activeFrameRect: FrameRect {
        if isPinching {
            return frameRect
        }
        if hasLockedFrame {
            return lockedFrameRect
        }
        return .hidden
    }

    func clearLockedFrame() {
        frameRect = .hidden
        lockedFrameRect = .hidden
        hasLockedFrame = false
        isPinching = false
        pinchAnchorPoint = nil
        lastDragPoint = nil
        capturedPuzzleImage = nil
        puzzleBoard = nil
        selectedTile = nil
        resetGameProgress()
        statusMessage = handDetected
            ? "Pinch thumb and index together to start framing."
            : "Show your full hand to begin."
    }

    func onAppear() {
        cameraService.checkPermission()
    }

    func onDisappear() {
        stopTimer()
        cameraService.stopSession()
        handCameraService.stopSession()
    }

    func setMode(_ mode: GameMode) {
        currentMode = mode
    }

    func toggleCamera() {
        handPoints = []
        handConnections = []
        handDetected = false
        isPinching = false
        frameRect = .hidden
        lockedFrameRect = .hidden
        hasLockedFrame = false
        pinchAnchorPoint = nil
        lastDragPoint = nil
        capturedPuzzleImage = nil
        puzzleBoard = nil
        selectedTile = nil
        resetGameProgress()
        statusMessage = "Switching camera..."
        cameraService.toggleCamera()
    }
}
