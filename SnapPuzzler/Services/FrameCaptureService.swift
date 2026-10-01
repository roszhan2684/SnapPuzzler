//
//  FrameCaptureService.swift
//  SnapPuzzler
//

import Foundation
import UIKit
import CoreGraphics
import AVFoundation
import CoreImage
import ImageIO

final class FrameCaptureService {
    private let ciContext = CIContext()

    func portraitImageFromSampleBuffer(
        _ sampleBuffer: CMSampleBuffer,
        cameraPosition: AVCaptureDevice.Position
    ) -> UIImage? {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return nil
        }

        let baseImage = CIImage(cvPixelBuffer: pixelBuffer)

        let orientedImage: CIImage
        switch cameraPosition {
        case .front:
            orientedImage = baseImage.oriented(.upMirrored)
        case .back:
            orientedImage = baseImage.oriented(.up)
        default:
            orientedImage = baseImage.oriented(.up)
        }

        guard let cgImage = ciContext.createCGImage(orientedImage, from: orientedImage.extent) else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }

    func cropImage(
        _ image: UIImage,
        normalizedRect: CGRect
    ) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }

        let imageWidth = CGFloat(cgImage.width)
        let imageHeight = CGFloat(cgImage.height)

        var cropRect = CGRect(
            x: normalizedRect.origin.x * imageWidth,
            y: normalizedRect.origin.y * imageHeight,
            width: normalizedRect.size.width * imageWidth,
            height: normalizedRect.size.height * imageHeight
        ).integral

        cropRect.origin.x = max(0, min(cropRect.origin.x, imageWidth - 1))
        cropRect.origin.y = max(0, min(cropRect.origin.y, imageHeight - 1))
        cropRect.size.width = max(1, min(cropRect.size.width, imageWidth - cropRect.origin.x))
        cropRect.size.height = max(1, min(cropRect.size.height, imageHeight - cropRect.origin.y))

        guard let cropped = cgImage.cropping(to: cropRect) else { return nil }
        return UIImage(cgImage: cropped)
    }
}
