//
//  PredictionAlert.swift
//  HandTalk
//
//  Created by Darren Thiores on 20/02/24.
//

import SwiftUI

struct PredictionAlert: View {
    let resultCorrect: Bool
    let capturedImage: UIImage?
    let currentAlphabet: HandSign?
    let prediction: HandSign?
    let onNext: () -> Void
    
    var body: some View {
        ZStack {
            Color.black
                .opacity(0.2)
            
            VStack(alignment: .center) {
                Text(
                    resultCorrect ? "You Guessed It Right!"
                    : "Learn and Try Again Next Time!"
                )
                .font(.title)
                .multilineTextAlignment(.center)
                .fontWeight(.semibold)
                
                Spacer()
                    .frame(height: 16)
                
                Text(
                    resultCorrect ? "Let's try to guess the next hand sign, good luck!"
                    : "You make a hand sign of \(prediction?.rawValue ?? ""), below is the right hand sign"
                )
                .multilineTextAlignment(.center)
                .fontWeight(.medium)
                
                Spacer()
                    .frame(height: 32)
                
                Image(
                    uiImage: resultCorrect ? capturedImage ?? UIImage()
                    : currentAlphabet?.getImage() ?? UIImage()
                )
                .resizable()
                .scaledToFit()
                .clipShape(
                    RoundedRectangle(cornerRadius: 16)
                )
                
                Spacer()
                    .frame(height: 32)
                
                Button {
                    onNext()
                } label: {
                    Text("Next")
                        .frame(maxWidth: .infinity)
                }
                .accentColor(.Primary)
                .foregroundColor(.OnPrimary)
                .buttonStyle(.borderedProminent)
                .cornerRadius(16)
            }
            .foregroundColor(.OnBackground)
            .padding(32)
            .background(
                Color.Background
                    .opacity(0.8)
            )
            .clipShape(
                RoundedRectangle(cornerRadius: 16)
            )
            .shadow(radius: 1)
            .padding()
        }
    }
}

#Preview {
    PredictionAlert(
        resultCorrect: false,
        capturedImage: nil,
        currentAlphabet: .B,
        prediction: .A,
        onNext: {  }
    )
}
