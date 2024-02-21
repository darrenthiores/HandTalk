//
//  CameraView.swift
//  HandTalk
//
//  Created by Darren Thiores on 12/02/24.
//

import SwiftUI
import _PhotosUI_SwiftUI

struct DetectionView: View {
    @State private var prediction: String?
    @State private var errorMessage: String?
    @State private var overlayPoints: [CGPoint] = []
    let position: AVCaptureDevice.Position
    @State private var synthesizer = AVSpeechSynthesizer()
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .background(Color.PrimaryVariant)
            
            DetectionCameraView(
                predictionHandler: {
                    prediction = $0
                },
                errorMessageHandler: {
                    errorMessage = $0
                },
                pointsProcessorHandler: {
                    overlayPoints = $0
                },
                position: position,
                synthesizer: synthesizer
            )
            .background(.black)
            .overlay(
                FingersOverlay(
                    with: overlayPoints
                )
                .foregroundColor(.Primary)
            )
            
            HStack {
                Spacer()
                
                VStack(spacing: 16) {
                    Text(prediction ?? "Unknown")
                        .font(.title2)
                        .foregroundColor(.black)
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Detection")
        .navigationBarTitleDisplayMode(.inline)
        .background(
            Color.PrimaryVariant.ignoresSafeArea()
        )
    }
}

#Preview {
    DetectionView(
        position: .front
    )
}
