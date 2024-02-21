//
//  SwiftUIView.swift
//
//
//  Created by Darren Thiores on 14/02/24.
//

import SwiftUI
import AVFoundation

struct DetectionCameraView: UIViewControllerRepresentable {
    var predictionHandler: (String) -> Void
    var errorMessageHandler: (String) -> Void
    var pointsProcessorHandler: (([CGPoint]) -> Void)?
    var position: AVCaptureDevice.Position
    var synthesizer: AVSpeechSynthesizer
    
    func makeUIViewController(context: Context) -> DetectionCameraViewController {
        let cvc = DetectionCameraViewController()
        
        cvc.predictionHandler = predictionHandler
        cvc.errorMessageHandler = errorMessageHandler
        cvc.pointsProcessorHandler = pointsProcessorHandler
        cvc.position = position
        cvc.synthesizer = synthesizer
        
        return cvc
    }
    
    func updateUIViewController(
        _ uiViewController: DetectionCameraViewController,
        context: Context
    ) {
    }
}
