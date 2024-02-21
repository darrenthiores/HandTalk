import AVFoundation
import Vision

class HandPoseClassifier: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, ObservableObject {
    private let videoDataOutputQueue = DispatchQueue(label: "CameraFeedDataOutput", qos: .userInteractive)
    var cameraFeedSession: AVCaptureSession = .init()
    private var handPoseRequest = VNDetectHumanHandPoseRequest()
    private let handPoseClassifier: HandSignReader
    @Published var predictionResult: String?
    @Published var errorMessage: String?
    @Published var points: [CGPoint] = []
    
    var lastSampleDate = Date.distantPast
    let sampleInterval: TimeInterval = 2
    
    init(
        cameraPosition: AVCaptureDevice.Position
    ) {
        do {
            if let model = Classifier.model {
                handPoseClassifier = model
                super.init()
                try setupAVSession(
                    cameraPosition: cameraPosition
                )
            } else {
                fatalError("Failed to load MLModel")
            }
        } catch {
            fatalError("Failed to load camera")
        }
    }
    
    func setupAVSession(
        cameraPosition: AVCaptureDevice.Position
    ) throws {
        guard let videoDevice = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: cameraPosition
        ) else {
            self.errorMessage = "Can't find the camera"
            return
        }
        
        guard let deviceInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            self.errorMessage = "Can't create video device input"
            return
        }
        
        let session = AVCaptureSession()
        session.beginConfiguration()
        session.sessionPreset = AVCaptureSession.Preset.high
        
        // Add a video input.
        guard session.canAddInput(deviceInput) else {
            self.errorMessage = "Can't add video device input to the session"
            return
        }
        session.addInput(deviceInput)
        
        let dataOutput = AVCaptureVideoDataOutput()
        if session.canAddOutput(dataOutput) {
            session.addOutput(dataOutput)
            // Add a video data output.
            dataOutput.alwaysDiscardsLateVideoFrames = true
            dataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
            dataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        } else {
            self.errorMessage = "Can't add video data output to the session"
            return
        }
        session.commitConfiguration()
        session.startRunning()
        cameraFeedSession = session
    }
    
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        let currentDate = Date()
        guard currentDate.timeIntervalSince(lastSampleDate) >= sampleInterval else {
            return
        }
        
        lastSampleDate = currentDate
        
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
            
            var fingerTips: [CGPoint] = []
            
            defer {
              DispatchQueue.main.sync {
                points = fingerTips
              }
            }
            
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
            
            do {
                // Build input attributes from hand points and run prediction by custom mlmodel
                let output: HandSignReaderOutput = try handPoseClassifier.prediction(
                    poses: buildInputAttribute(
                        recognizedPoints: handPoint
                    )
                )
                
                // Print prediction result
                print(output.label)
                print(output.labelProbabilities)
                
                // Update prediction result by output label
                DispatchQueue.main.async {
                    self.predictionResult = output.label
                }
            }
        } catch let e {
            cameraFeedSession.stopRunning()
            fatalError(e.localizedDescription)
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
            return [Float(recognizedPoint.x), Float(recognizedPoint.y), Float(recognizedPoint.confidence)]
        } else {
            return [0.0, 0.0, 0.0]
        }
    }
}
