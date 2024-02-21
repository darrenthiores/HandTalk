//
//  CaptureButton.swift
//  HandTalk
//
//  Created by Darren Thiores on 20/02/24.
//

import SwiftUI

struct CaptureButton: View {
    let onClick: () -> Void
    
    var body: some View {
        Button{
            onClick()
        } label: {
            Circle()
                .foregroundColor(.Primary)
                .frame(
                    width: 70,
                    height: 70,
                    alignment: .center
                )
                .overlay(
                    Circle()
                        .stroke(
                            Color.PrimaryVariant,
                            lineWidth: 2
                        )
                        .frame(
                            width: 59,
                            height: 59,
                            alignment: .center
                        )
                )
        }
    }
}

#Preview {
    CaptureButton(
        onClick: {  }
    )
}
