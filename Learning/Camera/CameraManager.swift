//
//  File.swift
//
//
//  Created by Darren Thiores on 19/02/24.
//

import Foundation
import AVFoundation
import SwiftUI

class CameraManager: ObservableObject {
    
    // Represents the camera's status
    enum Status {
        case configured
        case unconfigured
        case unauthorized
        case failed
    }
    
    // Observes changes in the camera's status
    @Published var status = Status.unconfigured
    @Published var capturedImage: UIImage? = nil
    @Published var showErrorAlert = false
    
    
    let session = AVCaptureSession()
    let photoOutput = AVCapturePhotoOutput()
    var videoDeviceInput: AVCaptureDeviceInput?
    
    var position: AVCaptureDevice.Position = .back
    
    private var cameraDelegate: CameraDelegate?
    
    var error: String?
    
    private let sessionQueue = DispatchQueue(label: "com.darrenthiores.sessionQueue")
    
    func configureCaptureSession() {
        sessionQueue.async { [weak self] in
            guard let self, self.status == .unconfigured else { return }
            
            self.session.beginConfiguration()
            self.session.sessionPreset = .photo
            
            self.setupVideoInput()
            self.setupPhotoOutput()
            
            self.session.commitConfiguration()
            
            self.startCapturing()
        }
    }
    
    private func setupVideoInput() {
        do {
            let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position)
            
            guard let camera else {
                print("CameraManager: Video device is unavailable.")
                status = .unconfigured
                session.commitConfiguration()
                return
            }
            
            let videoInput = try AVCaptureDeviceInput(device: camera)
            
            if session.canAddInput(videoInput) {
                session.addInput(videoInput)
                videoDeviceInput = videoInput
                status = .configured
            } else {
                print("CameraManager: Couldn't add video device input to the session.")
                status = .unconfigured
                session.commitConfiguration()
                return
            }
        } catch {
            print("CameraManager: Couldn't create video device input: \(error)")
            status = .failed
            session.commitConfiguration()
            return
        }
    }
    
    private func setupPhotoOutput() {
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
            
            photoOutput.isHighResolutionCaptureEnabled = true
            photoOutput.maxPhotoQualityPrioritization = .quality
            
            status = .configured
        } else {
            print("CameraManager: Could not add photo output to the session")
            
            status = .failed
            session.commitConfiguration()
            
            return
        }
    }
    
    private func startCapturing() {
        if status == .configured {
            self.session.startRunning()
        } else if status == .unconfigured || status == .unauthorized {
            DispatchQueue.main.async {
                self.error = "Camera configuration failed. Either your device camera is not available or its missing permissions"
                self.showErrorAlert = true
            }
        }
    }
    
    func stopCapturing() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }
    
    func switchCamera() {
        position = position == .back ? .front : .back
        
        guard let videoDeviceInput else { return }
        
        session.removeInput(videoDeviceInput)
        
        setupVideoInput()
    }
    
    func captureImage() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            
            var photoSettings = AVCapturePhotoSettings()
            
            // Capture HEIC photos when supported
            if photoOutput.availablePhotoCodecTypes.contains(.hevc) {
                photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
            }
            
            photoSettings.isHighResolutionPhotoEnabled = true
            
            // Specify photo quality and preview format
            if let previewPhotoPixelFormatType = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
                photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPhotoPixelFormatType]
            }
            
            photoSettings.photoQualityPrioritization = .quality
            
            if let videoConnection = photoOutput.connection(with: .video), videoConnection.isVideoOrientationSupported {
                videoConnection.videoOrientation = .portrait
            }
            
            cameraDelegate = CameraDelegate { [weak self] image in
                self?.capturedImage = image
            }
            
            if let cameraDelegate {
                // Capture the photo with delegate
                self.photoOutput.capturePhoto(with: photoSettings, delegate: cameraDelegate)
            }
        }
    }
}
