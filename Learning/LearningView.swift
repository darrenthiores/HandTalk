//
//  LearningView.swift
//  HandTalk
//
//  Created by Darren Thiores on 19/02/24.
//

import SwiftUI

struct LearningView: View {
    @StateObject private var viewModel = LearningViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading) {
                Text("Guess the Hand Sign")
                    .font(.title2)
                
                Spacer()
                    .frame(height: 8)
                
                HStack {
                    Text(viewModel.state.currentSign?.rawValue ?? "")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Button {
                        viewModel.onEvent(
                            event: .Next
                        )
                    } label: {
                        Image(systemName: "arrow.circlepath")
                            .font(.title)
                    }
                    .accentColor(.Primary)
                    .foregroundColor(.Primary)
                    .disabled(viewModel.state.isProcessingImage)
                }
            }
            .padding()
            
            LearnCameraView(session: viewModel.session)
            
            HStack {
                Spacer()
                    .frame(width: 45, height: 45)
                
                Spacer()
                
                CaptureButton(
                    onClick: {
                        viewModel.onEvent(
                            event: .CaptureImage
                        )
                    }
                )
                .disabled(viewModel.state.isProcessingImage)
                
                Spacer()
                
                SwitchButton(
                    onClick: {
                        viewModel.onEvent(
                            event: .SwitchCamera
                        )
                    }
                )
            }
            .padding()
        }
        .navigationTitle("Learn")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.onEvent(
                event: .Initialization
            )
        }
        .alert(isPresented: $viewModel.state.showErrorAlert) {
            Alert(
                title: Text("Error"),
                message: Text(viewModel.state.error ?? "Unknown Error Just Occurred"),
                dismissButton: .default(
                    Text("Try Again")
                )
            )
        }
        .alert(isPresented: $viewModel.state.showSettingAlert) {
            Alert(
                title: Text("Warning"),
                message: Text("Application doesn't have all permissions to use camera and microphone, please change privacy settings."),
                dismissButton: .default(
                    Text("Go to settings"),
                    action: {
                        self.openSettings()
                    }
                )
            )
        }
        .overlay(alignment: .center) {
            if viewModel.state.showPredictionAlert {
                let resultCorrect = viewModel.state.currentSign == viewModel.state.predictionResult
                
                PredictionAlert(
                    resultCorrect: resultCorrect,
                    capturedImage: viewModel.state.capturedImage,
                    currentAlphabet: viewModel.state.currentSign,
                    prediction: viewModel.state.predictionResult,
                    onNext: {
                        viewModel.onEvent(
                            event: .Next
                        )
                    }
                )
            }
        }
        .background(
            Color.PrimaryVariant
                .ignoresSafeArea()
        )
        .foregroundColor(.black)
    }
    
    private func openSettings() {
        let settingsUrl = URL(string: UIApplication.openSettingsURLString)
        if let url = settingsUrl {
            UIApplication.shared.open(url, options: [:])
        }
    }
}

#Preview {
    LearningView()
}
