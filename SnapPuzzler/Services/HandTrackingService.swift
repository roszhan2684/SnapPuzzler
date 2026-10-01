//
//  HandTrackingService.swift
//  SnapPuzzler
//
//  Created by ROSZHAN RAJ on 15/03/26.
//

import Foundation
import AVFoundation
import Vision
import Combine
import CoreGraphics
import ImageIO

final class HandTrackingService: NSObject, ObservableObject {
    @Published var points: [HandPoint] = []
    @Published var connections: [HandConnection] = []
    @Published var handDetected: Bool = false

    private let processingQueue = DispatchQueue(label: "snappuzzler.handtracking.queue")
    private var isProcessingFrame = false
    private var currentCameraPosition: AVCaptureDevice.Position = .back

    private let jointNames: [VNHumanHandPoseObservation.JointName] = [
        .wrist,
        .thumbCMC, .thumbMP, .thumbIP, .thumbTip,
        .indexMCP, .indexPIP, .indexDIP, .indexTip,
        .middleMCP, .middlePIP, .middleDIP, .middleTip,
        .ringMCP, .ringPIP, .ringDIP, .ringTip,
        .littleMCP, .littlePIP, .littleDIP, .littleTip
    ]

    func updateCameraPosition(_ position: AVCaptureDevice.Position) {
        currentCameraPosition = position
    }

    private func jointNameString(_ joint: VNHumanHandPoseObservation.JointName) -> String {
        switch joint {
        case .wrist: return "wrist"
        case .thumbCMC: return "thumbCMC"
        case .thumbMP: return "thumbMP"
        case .thumbIP: return "thumbIP"
        case .thumbTip: return "thumbTip"
        case .indexMCP: return "indexMCP"
        case .indexPIP: return "indexPIP"
        case .indexDIP: return "indexDIP"
        case .indexTip: return "indexTip"
        case .middleMCP: return "middleMCP"
        case .middlePIP: return "middlePIP"
        case .middleDIP: return "middleDIP"
        case .middleTip: return "middleTip"
        case .ringMCP: return "ringMCP"
        case .ringPIP: return "ringPIP"
        case .ringDIP: return "ringDIP"
        case .ringTip: return "ringTip"
        case .littleMCP: return "littleMCP"
        case .littlePIP: return "littlePIP"
        case .littleDIP: return "littleDIP"
        case .littleTip: return "littleTip"
        default: return "\(joint.rawValue)"
        }
    }

    private func makeConnections(from points: [HandPoint]) -> [HandConnection] {
        func point(named name: String) -> HandPoint? {
            points.first(where: { $0.name == name })
        }

        let pairs: [(String, String)] = [
            ("wrist", "thumbCMC"),
            ("thumbCMC", "thumbMP"),
            ("thumbMP", "thumbIP"),
            ("thumbIP", "thumbTip"),

            ("wrist", "indexMCP"),
            ("indexMCP", "indexPIP"),
            ("indexPIP", "indexDIP"),
            ("indexDIP", "indexTip"),

            ("wrist", "middleMCP"),
            ("middleMCP", "middlePIP"),
            ("middlePIP", "middleDIP"),
            ("middleDIP", "middleTip"),

            ("wrist", "ringMCP"),
            ("ringMCP", "ringPIP"),
            ("ringPIP", "ringDIP"),
            ("ringDIP", "ringTip"),

            ("wrist", "littleMCP"),
            ("littleMCP", "littlePIP"),
            ("littlePIP", "littleDIP"),
            ("littleDIP", "littleTip"),

            ("thumbCMC", "indexMCP"),
            ("indexMCP", "middleMCP"),
            ("middleMCP", "ringMCP"),
            ("ringMCP", "littleMCP")
        ]

        return pairs.compactMap { fromName, toName in
            guard let from = point(named: fromName),
                  let to = point(named: toName) else {
                return nil
            }
            return HandConnection(from: from, to: to)
        }
    }

    private func imageOrientationForCurrentCamera() -> CGImagePropertyOrientation {
        switch currentCameraPosition {
        case .front:
            return .left
        case .back:
            return .left
        default:
            return .left
        }
    }
}

extension HandTrackingService: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard !isProcessingFrame else { return }
        isProcessingFrame = true

        processingQueue.async { [weak self] in
            guard let self = self else { return }
            defer { self.isProcessingFrame = false }

            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

            let request = VNDetectHumanHandPoseRequest()
            request.maximumHandCount = 1

            let handler = VNImageRequestHandler(
                cvPixelBuffer: pixelBuffer,
                orientation: self.imageOrientationForCurrentCamera(),
                options: [:]
            )

            do {
                try handler.perform([request])

                guard let observation = request.results?.first else {
                    DispatchQueue.main.async {
                        self.handDetected = false
                        self.points = []
                        self.connections = []
                    }
                    return
                }

                let recognizedPoints = try observation.recognizedPoints(.all)
                var detectedPoints: [HandPoint] = []

                for joint in self.jointNames {
                    guard let recognizedPoint = recognizedPoints[joint],
                          recognizedPoint.confidence > 0.2 else {
                        continue
                    }

                    let handPoint = HandPoint(
                        name: self.jointNameString(joint),
                        point: CGPoint(
                            x: recognizedPoint.location.x,
                            y: recognizedPoint.location.y
                        ),
                        confidence: recognizedPoint.confidence
                    )

                    detectedPoints.append(handPoint)
                }

                let builtConnections = self.makeConnections(from: detectedPoints)

                DispatchQueue.main.async {
                    self.handDetected = detectedPoints.count >= 10
                    self.points = detectedPoints
                    self.connections = builtConnections
                }
            } catch {
                DispatchQueue.main.async {
                    self.handDetected = false
                    self.points = []
                    self.connections = []
                }
            }
        }
    }
}
