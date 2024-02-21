//
//  AlphabetView.swift
//  HandTalk
//
//  Created by Darren Thiores on 19/02/24.
//

import SwiftUI

struct HandSignView: View {
    let alphabet: HandSign
    let proxy: GeometryProxy
    
    private var fontSize: CGFloat {
        if alphabet.rawValue.count == 1 {
            CGFloat(120)
        } else if alphabet.rawValue.count <= 5 {
            CGFloat(40)
        } else {
            CGFloat(30)
        }
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Spacer()
            
            Text(alphabet.rawValue)
                .font(.system(size: fontSize))
            
            Spacer()
            
            Spacer()
                .frame(width: 16)
            
            Image(uiImage: alphabet.getImage() ?? UIImage())
                .resizable()
                .scaledToFit()
                .frame(
                    width: (proxy.size.width - 48) / 2 // 48 -> padding 24 + List padding +- 24
                )
                .clipShape(
                    RoundedRectangle(cornerRadius: 16)
                )
        }
        .foregroundColor(.OnPrimary)
        .padding(24)
        .background(
            RoundedRectangle(
                cornerRadius: 16
            )
            .foregroundColor(.Primary)
        )
    }
}

#Preview {
    GeometryReader { proxy in
        HandSignView(
            alphabet: .A,
            proxy: proxy
        )
    }
}
