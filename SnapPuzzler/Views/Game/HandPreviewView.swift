//
//  HandPreviewView.swift
//  SnapPuzzler
//

import SwiftUI
import AVFoundation

struct HandPreviewView: UIViewRepresentable {
    let session: AVCaptureSession
    let points: [HandPoint]
    let connections: [HandConnection]
    let cameraPosition: AVCaptureDevice.Position

    func makeUIView(context: Context) -> HandCameraPreviewView {
        let view = HandCameraPreviewView()
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        configurePreviewConnection(for: view.videoPreviewLayer)
        return view
    }

    func updateUIView(_ uiView: HandCameraPreviewView, context: Context) {
        uiView.videoPreviewLayer.session = session
        uiView.videoPreviewLayer.videoGravity = .resizeAspectFill
        configurePreviewConnection(for: uiView.videoPreviewLayer)

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
