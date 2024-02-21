//
//  SwitchButton.swift
//  HandTalk
//
//  Created by Darren Thiores on 20/02/24.
//

import SwiftUI

struct SwitchButton: View {
    let onClick: () -> Void
    
    var body: some View {
        Button {
            onClick()
        } label: {
            Circle()
                .foregroundColor(
                    Color.gray.opacity(0.3)
                )
                .frame(
                    width: 45,
                    height: 45,
                    alignment: .center
                )
                .overlay(
                    Image(
                        systemName: "camera.rotate.fill"
                    )
                    .foregroundColor(.white)
                )
        }
    }
}

#Preview {
    SwitchButton(
        onClick: {  }
    )
}
