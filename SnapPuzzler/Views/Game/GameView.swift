//
//  GameView.swift
//  SnapPuzzler
//
//  Created by ROSZHAN RAJ on 14/03/26.
//

import SwiftUI
import AVFoundation

struct GameView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: GameViewModel
    @State private var showSolvedOverlay: Bool = false
    @State private var showHUD: Bool = true
    @State private var hudHideWorkItem: DispatchWorkItem?

    init(viewModel: GameViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            Theme.spaceBlack.ignoresSafeArea()

            if viewModel.cameraService.permissionGranted {
                ZStack {
                    CameraPreviewView(
                        session: viewModel.cameraService.session,
                        points: viewModel.isUsingFrontHandTracking ? [] : viewModel.handPoints,
                        connections: viewModel.isUsingFrontHandTracking ? [] : viewModel.handConnections,
                        cameraPosition: viewModel.cameraService.currentCameraPosition,
                        previewLayerStore: viewModel.previewLayerStore
                    )
                    .ignoresSafeArea()

                    if let captured = viewModel.capturedPuzzleImage {
                        FrozenBackgroundView(image: captured.visiblePreviewImage)
                            .ignoresSafeArea()
                    }

                    if let board = viewModel.puzzleBoard, !board.isSolved {
                        PuzzleBoardView(
                            board: board,
                            frameRect: viewModel.lockedFrameRect,
                            selectedTile: viewModel.selectedTile,
                            onTileTap: { tile in
                                viewModel.selectTile(tile)
                            }
                        )
                        .ignoresSafeArea()
                    } else {
                        FrameOverlayView(
                            frameRect: viewModel.activeFrameRect,
                            gridSize: viewModel.currentMode.rawValue
                        )
                        .ignoresSafeArea()
                    }

                    if viewModel.isUsingFrontHandTracking && viewModel.capturedPuzzleImage == nil {
                        handPreview
                    }

                    if showSolvedOverlay {
                        solvedOverlay
                    }
                }
            } else {
                Theme.spaceBlack.ignoresSafeArea()
            }

            if showHUD {
                VStack {
                    topOverlay
                    Spacer()
                    bottomOverlay
                }
                .padding()
                .transition(.opacity)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            revealHUD()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            viewModel.onAppear()
            scheduleHUDHide()
        }
        .onDisappear {
            viewModel.onDisappear()
            hudHideWorkItem?.cancel()
        }
        .onChange(of: viewModel.puzzleBoard?.isSolved == true) {
            if viewModel.puzzleBoard?.isSolved != true {
                showSolvedOverlay = false
            }
        }
    }

    private var handPreview: some View {
        HandPreviewView(
            session: viewModel.handCameraService.session,
            points: viewModel.handPoints,
            connections: viewModel.handConnections,
            cameraPosition: .front
        )
        .frame(width: 140, height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Theme.neonCoral.opacity(0.4), lineWidth: 1)
        )
        .shadow(color: Theme.spaceBlack.opacity(0.4), radius: 10)
        .padding([.trailing, .bottom], 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
    }

    private func revealHUD() {
        withAnimation(.easeInOut(duration: 0.2)) {
            showHUD = true
        }
        scheduleHUDHide()
    }

    private func scheduleHUDHide() {
        hudHideWorkItem?.cancel()
        let workItem = DispatchWorkItem {
            withAnimation(.easeInOut(duration: 0.25)) {
                showHUD = false
            }
        }
        hudHideWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: workItem)
    }

    private var topOverlay: some View {
        VStack(spacing: 16) {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                        .frame(width: 52, height: 52)
                        .background(Theme.spaceBlack.opacity(0.6))
                        .clipShape(Circle())
                }

                Spacer()

                if viewModel.hasLockedFrame || viewModel.capturedPuzzleImage != nil {
                    Button {
                        viewModel.clearLockedFrame()
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.title3.bold())
                            .foregroundColor(.white)
                            .frame(width: 52, height: 52)
                            .background(Theme.spaceBlack.opacity(0.6))
                            .clipShape(Circle())
                    }
                }

                Button {
                    viewModel.toggleCamera()
                } label: {
                    Image(systemName: "camera.rotate")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                        .frame(width: 52, height: 52)
                        .background(Theme.spaceBlack.opacity(0.6))
                        .clipShape(Circle())
                }
            }

            HStack {
                Text(viewModel.title)
                    .font(ThemeFont.title(28))
                    .foregroundColor(.white)

                Spacer()

                Text(viewModel.currentMode.title)
                    .font(ThemeFont.body(14))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Theme.spaceBlack.opacity(0.6))
                    .clipShape(Capsule())
            }

            HStack(spacing: 12) {
                statPill(title: "Time", value: formattedElapsedTime)
                statPill(title: "Moves", value: "\(viewModel.moveCount)")
            }

            Picker("Grid Size", selection: $viewModel.currentMode) {
                ForEach(GameMode.allCases) { mode in
                    Text(mode.title).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .tint(Theme.neonCoral)
        }
    }

    private func statPill(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(ThemeFont.body(12))
                .foregroundColor(.white.opacity(0.7))
            Text(value)
                .font(ThemeFont.body(16))
                .foregroundColor(.white)
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(Theme.spaceBlack.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Theme.neonCoral.opacity(0.2), lineWidth: 1)
        )
    }

    private var bottomOverlay: some View {
        VStack(spacing: 14) {
            if viewModel.permissionDenied {
                VStack(spacing: 8) {
                    Text("Camera Access Needed")
                        .font(ThemeFont.body(16))
                        .foregroundColor(.white)

                    Text("Enable camera permission in Settings to use the live puzzle capture.")
                        .font(ThemeFont.body(13))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Theme.neonCoral.opacity(0.35))
                .clipShape(RoundedRectangle(cornerRadius: 18))
            } else {
                VStack(spacing: 10) {
                    Image(systemName: bottomStatusIcon)
                        .font(.system(size: 34))
                        .foregroundColor(.white)

                    Text(viewModel.statusMessage)
                        .font(ThemeFont.body(13))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Theme.spaceBlack.opacity(0.6))
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Theme.neonCoral.opacity(0.2), lineWidth: 1)
                )
            }

            if viewModel.puzzleBoard?.isSolved == true && !showSolvedOverlay {
                Button {
                    showSolvedOverlay = true
                } label: {
                    Text("View Result")
                        .font(ThemeFont.body(16))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Theme.neonCoral)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
        }
    }

    private var solvedOverlay: some View {
        VStack(spacing: 16) {
            Text("Puzzle Solved!")
                .font(ThemeFont.title(24))
                .foregroundColor(.white)

            HStack(spacing: 16) {
                VStack(spacing: 4) {
                    Text("Time")
                        .font(ThemeFont.body(12))
                        .foregroundColor(.white.opacity(0.7))
                    Text(formattedElapsedTime)
                        .font(ThemeFont.body(18))
                        .foregroundColor(.white)
                }

                VStack(spacing: 4) {
                    Text("Moves")
                        .font(ThemeFont.body(12))
                        .foregroundColor(.white.opacity(0.7))
                    Text("\(viewModel.moveCount)")
                        .font(ThemeFont.body(18))
                        .foregroundColor(.white)
                }
            }

            HStack(spacing: 12) {
                Button {
                    showSolvedOverlay = false
                    viewModel.playAgain()
                } label: {
                    Text("Play Again")
                        .font(ThemeFont.body(16))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Theme.neonCoral)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Button {
                    showSolvedOverlay = false
                    viewModel.clearLockedFrame()
                } label: {
                    Text("New Snap")
                        .font(ThemeFont.body(16))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Theme.spaceBlack.opacity(0.7))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Theme.neonCoral.opacity(0.3), lineWidth: 1)
                        )
                }
            }
        }
        .padding(20)
        .frame(maxWidth: 320)
        .background(Theme.spaceBlack.opacity(0.85))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Theme.neonCoral.opacity(0.4), lineWidth: 1)
        )
    }

    private var bottomStatusIcon: String {
        if viewModel.puzzleBoard != nil {
            return "square.grid.3x3.fill"
        } else if viewModel.capturedPuzzleImage != nil {
            return "photo"
        } else if viewModel.isPinching {
            return "viewfinder"
        } else if viewModel.handDetected {
            return "hand.raised.fill"
        } else {
            return "camera.viewfinder"
        }
    }

    private var formattedElapsedTime: String {
        let totalSeconds = Int(viewModel.elapsedTime.rounded())
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
