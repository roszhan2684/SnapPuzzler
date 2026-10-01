//
//  CameraPreviewView.swift
//  SnapPuzzler
//
//  Created by ROSZHAN RAJ on 14/03/26.
//

import SwiftUI
import AVFoundation

struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession
    let points: [HandPoint]
    let connections: [HandConnection]
    let cameraPosition: AVCaptureDevice.Position
    let previewLayerStore: PreviewLayerStore

    func makeUIView(context: Context) -> HandCameraPreviewView {
        let view = HandCameraPreviewView()
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        configurePreviewConnection(for: view.videoPreviewLayer)
        previewLayerStore.attach(view.videoPreviewLayer)
        return view
    }

    func updateUIView(_ uiView: HandCameraPreviewView, context: Context) {
        uiView.videoPreviewLayer.session = session
        uiView.videoPreviewLayer.videoGravity = .resizeAspectFill
        configurePreviewConnection(for: uiView.videoPreviewLayer)
        previewLayerStore.attach(uiView.videoPreviewLayer)

        uiView.updateOverlay(
            points: points,
            connections: connections
        )
    }

    private func configurePreviewConnection(for previewLayer: AVCaptureVideoPreviewLayer) {
        guard let connection = previewLayer.connection else { return }

        if connection.isVideoRotationAngleSupported(90) {
            connection.videoRotationAngle = 90
        }

        if connection.isVideoMirroringSupported {
            connection.automaticallyAdjustsVideoMirroring = false
            connection.isVideoMirrored = (cameraPosition == .front)
        }
    }
}

final class HandCameraPreviewView: UIView {
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        guard let layer = layer as? AVCaptureVideoPreviewLayer else {
            fatalError("Expected AVCaptureVideoPreviewLayer")
        }
        return layer
    }

    private let skeletonLayer = CAShapeLayer()
    private let pointsContainerLayer = CALayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupOverlayLayers()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupOverlayLayers()
    }

    private func setupOverlayLayers() {
        skeletonLayer.strokeColor = UIColor.white.withAlphaComponent(0.95).cgColor
        skeletonLayer.fillColor = UIColor.clear.cgColor
        skeletonLayer.lineWidth = 2.5
        skeletonLayer.lineJoin = .round
        skeletonLayer.lineCap = .round

        layer.addSublayer(skeletonLayer)
        layer.addSublayer(pointsContainerLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        skeletonLayer.frame = bounds
        pointsContainerLayer.frame = bounds
    }

    func updateOverlay(
        points: [HandPoint],
        connections: [HandConnection]
    ) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        let path = UIBezierPath()

        for connection in connections {
            let from = convertCapturePointToLayerPoint(connection.from.point)
            let to = convertCapturePointToLayerPoint(connection.to.point)

            path.move(to: from)
            path.addLine(to: to)
        }

        skeletonLayer.path = path.cgPath

        pointsContainerLayer.sublayers?.forEach { $0.removeFromSuperlayer() }

        for point in points {
            let layerPoint = convertCapturePointToLayerPoint(point.point)

            let dot = CAShapeLayer()
            let isFingerTip = fingertipNames.contains(point.name)
            let isWrist = point.name == "wrist"

            let size: CGFloat = isFingerTip ? 14 : (isWrist ? 12 : 9)
            let color: UIColor = isFingerTip ? .systemGreen : (isWrist ? .systemYellow : .white)

            let rect = CGRect(
                x: layerPoint.x - size / 2,
                y: layerPoint.y - size / 2,
                width: size,
                height: size
            )

            dot.path = UIBezierPath(ovalIn: rect).cgPath
            dot.fillColor = color.cgColor
            dot.strokeColor = UIColor.black.withAlphaComponent(0.25).cgColor
            dot.lineWidth = 1

            pointsContainerLayer.addSublayer(dot)
        }

        CATransaction.commit()
    }

    private func convertCapturePointToLayerPoint(_ point: CGPoint) -> CGPoint {
        let capturePoint = CGPoint(x: point.x, y: 1 - point.y)
        return videoPreviewLayer.layerPointConverted(fromCaptureDevicePoint: capturePoint)
    }

    private var fingertipNames: Set<String> {
        ["thumbTip", "indexTip", "middleTip", "ringTip", "littleTip"]
    }
}
