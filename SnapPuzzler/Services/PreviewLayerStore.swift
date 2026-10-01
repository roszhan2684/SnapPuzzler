//
//  PreviewLayerStore.swift
//  SnapPuzzler
//

import Foundation
import AVFoundation
import CoreGraphics

final class PreviewLayerStore {
    weak var previewLayer: AVCaptureVideoPreviewLayer?

    func attach(_ previewLayer: AVCaptureVideoPreviewLayer) {
        self.previewLayer = previewLayer
    }

    func normalizedCaptureRect(for frameRect: FrameRect) -> CGRect? {
        guard let previewLayer else { return nil }

        let bounds = previewLayer.bounds
        guard bounds.width > 0, bounds.height > 0 else { return nil }

        let layerRect = CGRect(
            x: (frameRect.center.x - frameRect.size.width / 2) * bounds.width,
            y: (frameRect.center.y - frameRect.size.height / 2) * bounds.height,
            width: frameRect.size.width * bounds.width,
            height: frameRect.size.height * bounds.height
        )

        let topLeft = previewLayer.captureDevicePointConverted(
            fromLayerPoint: CGPoint(x: layerRect.minX, y: layerRect.minY)
        )

        let bottomRight = previewLayer.captureDevicePointConverted(
            fromLayerPoint: CGPoint(x: layerRect.maxX, y: layerRect.maxY)
        )

        let minX = min(topLeft.x, bottomRight.x)
        let maxX = max(topLeft.x, bottomRight.x)
        let minY = min(topLeft.y, bottomRight.y)
        let maxY = max(topLeft.y, bottomRight.y)

        return CGRect(
            x: minX,
            y: minY,
            width: maxX - minX,
            height: maxY - minY
        )
    }

    func normalizedVisiblePreviewRect() -> CGRect? {
        guard let previewLayer else { return nil }
        return previewLayer.metadataOutputRectConverted(fromLayerRect: previewLayer.bounds)
    }

    var livePreviewRotationAngle: CGFloat {
        guard let connection = previewLayer?.connection else { return 90 }
        return connection.videoRotationAngle
    }

    var isLivePreviewMirrored: Bool {
        guard let connection = previewLayer?.connection else { return false }
        return connection.isVideoMirrored
    }
}
