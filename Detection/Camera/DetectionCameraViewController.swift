//
//  SwiftUIView.swift
//
//
//  Created by Darren Thiores on 14/02/24.
//

import UIKit
import AVFoundation
import Vision

final class DetectionCameraViewController: UIViewController {
    private var cameraView: CameraPreview { view as! CameraPreview }
    
    private let videoDataOutputQueue = DispatchQueue(
        label: "CameraFeedOutput",
        qos: .userInteractive
    )
    private var cameraFeedSession: AVCaptureSession?
    private let handPoseRequest: VNDetectHumanHandPoseRequest = VNDetectHumanHandPoseRequest()
    private var handPoseClassifier: HandSignReader {
        if let model = Classifier.model {
            return model
        } else {
            fatalError("Failed to load MLModel")
        }
    }
    
    var predictionHandler: (String) -> Void = { _ in }
    var errorMessageHandler: (String) -> Void = { _ in  }
    var pointsProcessorHandler: (([CGPoint]) -> Void)?
    var position: AVCaptureDevice.Position?
    var synthesizer: AVSpeechSynthesizer?
    
    var lastSampleDate = Date.distantPast
    let sampleInterval: TimeInterval = 2
    
    override func loadView() {
        view = CameraPreview()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        do {
            if cameraFeedSession == nil {
                try setupAVSession(
                    position: position
                )
                cameraView.previewLayer.session = cameraFeedSession
                cameraView.previewLayer.videoGravity = .resizeAspectFill
            }
            
            DispatchQueue.main.async {
                self.cameraFeedSession?.startRunning()
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        cameraFeedSession?.stopRunning()
        super.viewWillDisappear(animated)
    }
    
    func setupAVSession(
        position: AVCaptureDevice.Position?
    ) throws {
        guard let videoDevice = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: position ?? .front
        )
        else {
            errorMessageHandler(
                "Could not find a front facing camera."
            )
            
            return
        }
        
        guard let deviceInput = try? AVCaptureDeviceInput(
            device: videoDevice
        ) else {
            errorMessageHandler(
                "Could not create video device input."
            )
            
            return
        }
        
        let session = AVCaptureSession()
        session.beginConfiguration()
        session.sessionPreset = AVCaptureSession.Preset.high
        
        // Add a video input.
        guard session.canAddInput(deviceInput) else {
            errorMessageHandler(
                "Could not add video device input to the session"
            )
            
            return
        }
        session.addInput(deviceInput)
        
        let dataOutput = AVCaptureVideoDataOutput()
        if session.canAddOutput(dataOutput) {
            session.addOutput(dataOutput)
            // Add a video data output.
            dataOutput.alwaysDiscardsLateVideoFrames = true
            dataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        } else {
            errorMessageHandler(
                "Could not add video data output to the session"
            )
        }
        session.commitConfiguration()
        cameraFeedSession = session
    }
    
    func processPoints(_ fingerTips: [CGPoint]) {
        // Convert points from AVFoundation coordinates to UIKit coordinates.
        let convertedPoints = fingerTips.map {
            cameraView.previewLayer.layerPointConverted(fromCaptureDevicePoint: $0)
        }
        pointsProcessorHandler?(convertedPoints)
    }
}

extension
DetectionCameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        var fingerTips: [CGPoint] = []
        
        defer {
            DispatchQueue.main.sync {
                self.processPoints(fingerTips)
            }
        }
        
        let handler = VNImageRequestHandler(
            cmSampleBuffer: sampleBuffer,
            orientation: .up,
            options: [:]
        )
        do {
            try handler.perform([handPoseRequest])
            
            guard let observation = handPoseRequest.results?.first else {
                return
            }
            
            let handPoint = try observation.recognizedPoints(.all)
            
            let fingers = [
                handPoint[.wrist],
                handPoint[.thumbCMC],
                handPoint[.thumbMP],
                handPoint[.thumbIP],
                handPoint[.thumbTip],
                handPoint[.indexMCP],
                handPoint[.indexPIP],
                handPoint[.indexDIP],
                handPoint[.indexTip],
                handPoint[.middleMCP],
                handPoint[.middlePIP],
                handPoint[.middleDIP],
                handPoint[.middleTip],
                handPoint[.ringMCP],
                handPoint[.ringPIP],
                handPoint[.ringDIP],
                handPoint[.ringTip],
                handPoint[.littleMCP],
                handPoint[.littlePIP],
                handPoint[.littleDIP],
                handPoint[.littleTip]
            ]
            
            fingerTips = fingers.filter {
                // Ignore low confidence points.
                $0 != nil && $0!.confidence > 0.9
            }
            .map {
                // Convert points from Vision coordinates to AVFoundation coordinates.
                CGPoint(x: $0!.location.x, y: 1 - $0!.location.y)
            }
            
            if handPoint.isEmpty {
                return
            }
            
            guard let keypointsMultiArray = try? observation.keypointsMultiArray() else { fatalError() }
            
            do {
                let currentDate = Date()
                guard currentDate.timeIntervalSince(self.lastSampleDate) >= self.sampleInterval else {
                    return
                }
                
                self.lastSampleDate = currentDate
                
                let output: HandSignReaderOutput = try handPoseClassifier.prediction(
                    poses: keypointsMultiArray
                )
                
                // Print prediction result
                print(output.label)
                print(output.labelProbabilities)
                
                // Update prediction result by output label
                DispatchQueue.main.async {
                    self.predictionHandler(output.label)
                    self.speak(text: output.label)
                }
            }
            
        } catch {
            cameraFeedSession?.stopRunning()
            print(error.localizedDescription)
        }
    }
    
    private func buildInputAttribute(recognizedPoints: [VNHumanHandPoseObservation.JointName : VNRecognizedPoint]) -> MLMultiArray {
        let attributeArray = buildRow(recognizedPoint: recognizedPoints[.wrist]) +
        buildRow(recognizedPoint: recognizedPoints[.thumbCMC]) +
        buildRow(recognizedPoint: recognizedPoints[.thumbMP]) +
        buildRow(recognizedPoint: recognizedPoints[.thumbIP]) +
        buildRow(recognizedPoint: recognizedPoints[.thumbTip]) +
        buildRow(recognizedPoint: recognizedPoints[.indexMCP]) +
        buildRow(recognizedPoint: recognizedPoints[.indexPIP]) +
        buildRow(recognizedPoint: recognizedPoints[.indexDIP]) +
        buildRow(recognizedPoint: recognizedPoints[.indexTip]) +
        buildRow(recognizedPoint: recognizedPoints[.middleMCP]) +
        buildRow(recognizedPoint: recognizedPoints[.middlePIP]) +
        buildRow(recognizedPoint: recognizedPoints[.middleDIP]) +
        buildRow(recognizedPoint: recognizedPoints[.middleTip]) +
        buildRow(recognizedPoint: recognizedPoints[.ringMCP]) +
        buildRow(recognizedPoint: recognizedPoints[.ringPIP]) +
        buildRow(recognizedPoint: recognizedPoints[.ringDIP]) +
        buildRow(recognizedPoint: recognizedPoints[.ringTip]) +
        buildRow(recognizedPoint: recognizedPoints[.littleMCP]) +
        buildRow(recognizedPoint: recognizedPoints[.littlePIP]) +
        buildRow(recognizedPoint: recognizedPoints[.littleDIP]) +
        buildRow(recognizedPoint: recognizedPoints[.littleTip]
        )
        
        let attributeBuffer = UnsafePointer(attributeArray)
        let mlArray = try! MLMultiArray(shape: [1, 3, 21], dataType: MLMultiArrayDataType.float)
        
        mlArray.dataPointer.initializeMemory(as: Float.self, from: attributeBuffer, count: attributeArray.count)
        
        return mlArray
    }
    
    private func buildRow(recognizedPoint: VNRecognizedPoint?) -> [Float] {
        if let recognizedPoint = recognizedPoint {
            if recognizedPoint.confidence > 0.9 {
                return [Float(recognizedPoint.x), Float(recognizedPoint.y), Float(recognizedPoint.confidence)]
            } else {
                return [0.0, 0.0, 0.0]
            }
        } else {
            return [0.0, 0.0, 0.0]
        }
    }
    
    private func speak(text: String) {
        let audioSession = AVAudioSession()
        
        do {
            try audioSession.setCategory(.playback, mode: .default, options: .duckOthers)
            try audioSession.setActive(false)
        } catch let error {
            print("Setup audio session error", error.localizedDescription)
        }
        
        let utterance = AVSpeechUtterance(string: text)
        
        utterance.rate = 0.57
        utterance.pitchMultiplier = 0.8
        utterance.postUtteranceDelay = 0.2
        utterance.volume = 0.8
        
        let voice = AVSpeechSynthesisVoice(language: "en-US")
        
        utterance.voice = voice
        
        self.synthesizer?.speak(utterance)
    }
}
