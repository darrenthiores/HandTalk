//
//  BoardingView.swift
//  HandTalk
//
//  Created by Darren Thiores on 20/02/24.
//

import SwiftUI

struct BoardingView: View {
    @State private var currentSection: BoardingSection = .One
    @State private var isLoading: Bool = false
    
    var body: some View {
        GeometryReader { proxy in
            switch currentSection {
            case .One:
                BoardingSectionView(
                    imageName: "Boarding1",
                    title: "Learn Hand Sign",
                    description: "Learn basic hand sign with the help of Machine Learning, and let's connect with people that use hand language!",
                    onNext: {
                        currentSection = .Two
                    },
                    proxy: proxy
                )
            case .Two:
                BoardingSectionView(
                    imageName: "Boarding2",
                    title: "Understand Hand Language",
                    description: "Use HandTalk's camera to detect hand pose of a person, and let the app translate and read it for you!",
                    onNext: {
                        currentSection = .Three
                    },
                    proxy: proxy
                )
            case .Three:
                BoardingSectionView(
                    imageName: "Boarding3",
                    title: "Let People Understand",
                    description: "Not everyone understand hand language? use HandTalk's camera and let the app talks for you!",
                    onNext: {
                        isLoading = true
                        hideBoarding()
                    },
                    isLast: true,
                    isLoading: isLoading,
                    proxy: proxy
                )
            }
        }
        .background(
            Color.PrimaryVariant
                .ignoresSafeArea()
        )
    }
    
    private func hideBoarding() {
        DispatchQueue.main.async {
            let userDefaults = UserDefaults.standard
            
            userDefaults.set(false, forKey: "showBoarding")
        }
    }
}

#Preview {
    BoardingView()
}
