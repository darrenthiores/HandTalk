//
//  File.swift
//
//
//  Created by Darren Thiores on 20/02/24.
//

import Foundation
import SwiftUI
import AVFoundation

struct LearnCameraView: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> CameraPreview {
        let view = CameraPreview()
        view.backgroundColor = .black
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspect
        view.previewLayer.connection?.videoOrientation = .portrait
        
        return view
    }
    
    func updateUIView(_ uiView: CameraPreview, context: Context) {
        
    }
}
