//
//  SwiftUIView.swift
//  
//
//  Created by Darren Thiores on 19/02/24.
//

import SwiftUI

struct MainView: View {
    @State private var currentPosition: CameraPosition = .Front
    @State private var showUpButton: Bool = false
    
    var body: some View {
        GeometryReader { geoProxy in
            ScrollViewReader { proxy in
                ZStack {
                    List {
                        Section {
                            LearnCard()
                        } header: {
                            Text("Learn with ML")
                        }
                        .id("top")
                        .onAppear {
                            showUpButton = false
                        }
                        .onDisappear {
                            showUpButton = true
                        }
                        .listRowBackground(Color.PrimaryVariant)
                        
                        Section {
                            ForEach(HandSign.allValues, id: \.rawValue) { alphabet in
                                HandSignView(
                                    alphabet: alphabet,
                                    proxy: geoProxy
                                )
                            }
                        } header: {
                            Text("Basic Hand Signs")
                        }
                        .listRowBackground(Color.PrimaryVariant)
                    }
                    .listStyle(.plain)
                    
                    if showUpButton {
                        ZStack(alignment: .bottomTrailing) {
                            Color.clear
                            
                            Button {
                                withAnimation {
                                    proxy.scrollTo("top", anchor: .top)
                                }
                            } label: {
                                Circle()
                                    .foregroundColor(Color.gray.opacity(0.5))
                                    .frame(width: 45, height: 45, alignment: .center)
                                    .overlay(
                                        Image(systemName: "arrow.up.to.line")
                                            .foregroundColor(.white)
                                    )
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("HandTalk")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 0) {
                        Button {
                            currentPosition = currentPosition == .Front ? .Back : .Front
                        } label: {
                            Image(systemName: "arrow.circlepath")
                                .foregroundColor(.Primary)
                        }
                        
                        Text(currentPosition.rawValue)
                            .foregroundColor(.black)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        DetectionView(
                            position: currentPosition == .Front ? .front : .back
                        )
                    } label: {
                        Image(systemName: "camera")
                            .foregroundColor(.Primary)
                    }
                }
            }
            .background(
                Color.PrimaryVariant
                    .ignoresSafeArea()
            )
            .colorScheme(.light)
        }
    }
}

#Preview {
    MainView()
}
