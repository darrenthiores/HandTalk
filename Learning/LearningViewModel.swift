//
//  LearningViewModel.swift
//  HandTalk
//
//  Created by Darren Thiores on 19/02/24.
//

import SwiftUI
import Combine
import Photos
import AVFoundation
import Vision

class LearningViewModel: ObservableObject {
    
    // Reference to the CameraManager.
    @ObservedObject private var cameraManager = CameraManager()

    @Published var state: LearningState = LearningState()
    
    var session: AVCaptureSession = .init()
    
    private var cancelables = Set<AnyCancellable>()
    
    private var handPoseClassifier: HandSignReader? {
        Classifier.model
    }
    
    init() {
        // Initialize the session with the cameraManager's session.
        session = cameraManager.session
        state.currentSign = HandSign.allValues.randomElement()
    }
    
    deinit {
        // Deinitializer to stop capturing when the ViewModel is deallocated.
        cameraManager.stopCapturing()
    }
    
    func onEvent(event: LearningEvent) {
        switch event {
        case .Initialization:
            setupBindings()
            configureCamera()
        case .RequestCameraPermission:
            requestCameraPermission()
        case .CaptureImage:
            cameraManager.captureImage()
        case .SwitchCamera:
            cameraManager.switchCamera()
        case .Next:
            state.currentSign = HandSign.allValues.randomElement()
            state.showPredictionAlert = false
            state.predictionResult = nil
            state.capturedImage = nil
        }
    }
    
    // Setup Combine bindings for handling publisher's emit values
    private func setupBindings() {
        cameraManager.$showErrorAlert.sink { [weak self] value in
            self?.state.error = self?.cameraManager.error
            self?.state.showErrorAlert = value
        }
        .store(in: &cancelables)
        
        cameraManager.$capturedImage.sink { [weak self] image in
            self?.state.capturedImage = image
            self?.predict()
        }.store(in: &cancelables)
    }
    
    // Check for camera device permission.
    private func checkForDevicePermission() {
        let videoStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if videoStatus == .authorized {
            // If Permission granted, configure the camera.
            state.permissionGranted = true
            configureCamera()
        } else if videoStatus == .notDetermined {
            // In case the user has not been asked to grant access we request permission
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { _ in })
        } else if videoStatus == .denied {
            // If Permission denied, show a setting alert.
            state.permissionGranted = false
            state.showSettingAlert = true
        }
    }
    
    private func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] isGranted in
            guard let self else { return }
            if isGranted {
                self.configureCamera()
                DispatchQueue.main.async {
                    self.state.permissionGranted = true
                }
            }
        }
    }
    
    private func configureCamera() {
//        checkForDevicePermission()
        cameraManager.configureCaptureSession()
    }
    
    private func predict() {
        state.isProcessingImage = true
        
        guard let cgImage = state.capturedImage?.cgImage else {
            state.isProcessingImage = false
            return
        }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage)
        
        let request = VNDetectHumanHandPoseRequest()
        request.maximumHandCount = 1
        
        do {
            // Perform the body pose-detection request.
            try requestHandler.perform([request])
            
            guard let observation = request.results?.first else {
                state.isProcessingImage = false
                return
            }
            
            guard let keypointsMultiArray = try? observation.keypointsMultiArray() else {
                state.error = "Something went wrong!"
                state.showErrorAlert = true
                state.isProcessingImage = false
                return
            }
            
            do {
                guard let classifier = handPoseClassifier else {
                    state.error = "ML Model is not configured!"
                    state.showErrorAlert = true
                    state.isProcessingImage = false
                    return
                }
                
                let output: HandSignReaderOutput = try classifier.prediction(
                    poses: keypointsMultiArray
                )
                
                // Print prediction result
                print(output.label)
                print(output.labelProbabilities)
                
                // Update prediction result by output label
                DispatchQueue.main.async {
                    self.state.predictionResult = HandSign(rawValue: output.label)
                    self.state.showPredictionAlert = true
                    self.state.isProcessingImage = false
                }
            }
        } catch {
            state.isProcessingImage = false
            print("Unable to perform the request: \(error).")
        }
    }
}
