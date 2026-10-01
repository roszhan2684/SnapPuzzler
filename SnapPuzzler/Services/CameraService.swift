//
//  CameraService.swift
//  SnapPuzzler
//
//  Created by ROSZHAN RAJ on 14/03/26.
//

import Foundation
import AVFoundation
import Combine

final class CameraService: NSObject, ObservableObject {
    @Published var permissionGranted = false
    @Published var isSessionRunning = false
    @Published var currentCameraPosition: AVCaptureDevice.Position = .back

    let session = AVCaptureSession()
    let videoOutput = AVCaptureVideoDataOutput()

    private let sessionQueue = DispatchQueue(label: "snappuzzler.camera.session.queue")
    private let outputProxy = VideoOutputProxy()

    override init() {
        super.init()
    }

    func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            DispatchQueue.main.async {
                self.permissionGranted = true
            }
            configureSession(position: currentCameraPosition)

        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    self.permissionGranted = granted
                }

                if granted {
                    self.configureSession(position: self.currentCameraPosition)
                }
            }

        case .denied, .restricted:
            DispatchQueue.main.async {
                self.permissionGranted = false
            }

        @unknown default:
            DispatchQueue.main.async {
                self.permissionGranted = false
            }
        }
    }

    func setCameraPosition(_ position: AVCaptureDevice.Position) {
        configureSession(position: position)
    }

    private func configureSession(position: AVCaptureDevice.Position) {
        sessionQueue.async {
            self.session.beginConfiguration()
            self.session.sessionPreset = .high

            self.session.inputs.forEach { self.session.removeInput($0) }

            guard
                let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position),
                let input = try? AVCaptureDeviceInput(device: camera),
                self.session.canAddInput(input)
            else {
                self.session.commitConfiguration()
                return
            }

            self.session.addInput(input)

            if self.session.outputs.isEmpty {
                if self.session.canAddOutput(self.videoOutput) {
                    self.videoOutput.alwaysDiscardsLateVideoFrames = true
                    self.videoOutput.videoSettings = [
                        kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
                    ]
                    self.session.addOutput(self.videoOutput)
                }
            }

            if let connection = self.videoOutput.connection(with: .video) {
                if connection.isVideoRotationAngleSupported(90) {
                    connection.videoRotationAngle = 90
                }
            }

            self.session.commitConfiguration()

            DispatchQueue.main.async {
                self.currentCameraPosition = position
            }

            self.startSession()
        }
    }

    func setVideoOutputDelegate(
        _ delegate: AVCaptureVideoDataOutputSampleBufferDelegate,
        queue: DispatchQueue
    ) {
        outputProxy.delegate = delegate
        videoOutput.setSampleBufferDelegate(outputProxy, queue: queue)
    }

    func clearVideoOutputDelegate() {
        outputProxy.delegate = nil
        videoOutput.setSampleBufferDelegate(nil, queue: nil)
    }

    func latestSampleBuffer() -> CMSampleBuffer? {
        outputProxy.latestSampleBuffer
    }

    func toggleCamera() {
        let newPosition: AVCaptureDevice.Position = currentCameraPosition == .back ? .front : .back
        configureSession(position: newPosition)
    }

    func startSession() {
        sessionQueue.async {
            guard !self.session.isRunning else { return }
            self.session.startRunning()

            DispatchQueue.main.async {
                self.isSessionRunning = true
            }
        }
    }

    func stopSession() {
        sessionQueue.async {
            guard self.session.isRunning else { return }
            self.session.stopRunning()

            DispatchQueue.main.async {
                self.isSessionRunning = false
            }
        }
    }
}

private final class VideoOutputProxy: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    weak var delegate: AVCaptureVideoDataOutputSampleBufferDelegate?
    private(set) var latestSampleBuffer: CMSampleBuffer?

    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        latestSampleBuffer = sampleBuffer
        delegate?.captureOutput?(output, didOutput: sampleBuffer, from: connection)
    }
}
