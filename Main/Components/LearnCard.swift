//
//  LearnCard.swift
//  HandTalk
//
//  Created by Darren Thiores on 19/02/24.
//

import SwiftUI

struct LearnCard: View {
    var body: some View {
        NavigationLink {
            LearningView()
        } label: {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Take Hand Sign Quiz")
                        .font(.title)
                        .fontWeight(.semibold)
                    
                    Text("Learn Hand Sign the Interactive Way with the help of ML")
                        .font(.headline)
                        .multilineTextAlignment(.leading)
                        .fontWeight(.medium)
                }
                
                Spacer()
            }
        }
        .foregroundColor(.OnPrimary)
        .padding(32)
        .background(
            Color.Primary
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 16
            )
        )
    }
}

#Preview {
    LearnCard()
}
