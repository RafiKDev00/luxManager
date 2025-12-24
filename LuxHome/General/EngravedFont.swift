//
//  EngravedFont.swift
//  LuxHome
//
//  Created by RJ  Kigner on 12/21/25.
//

import SwiftUI

struct EngravedFont: View {
    var text: String = "Default"
    var font: Font = .system(size: 40, weight: .bold)
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            if colorScheme == .dark {
                shadowLayer(color: .black.opacity(0.15), x: 0, y: -1.5)
                shadowLayer(color: .black.opacity(0.2), x: -1.5, y: 0)
                shadowLayer(color: .black.opacity(0.2), x: 1.5, y: 0)
                shadowLayer(color: .white.opacity(0.15), x: 0, y: 1.5)
            } else {
                shadowLayer(color: .black.opacity(0.01), x: 0, y: -0.5)
                shadowLayer(color: .black.opacity(0.01), x: -0.5, y: 0)
                shadowLayer(color: .black.opacity(0.01), x: 0.5, y: 0)
                shadowLayer(color: .white.opacity(0.9), x: 0, y: 0.5)
            }
            
            Text(text)
                .font(font)
                .foregroundColor(colorScheme == .dark ? Color(UIColor.secondaryLabel) : Color(UIColor.white).opacity(0.01))
                //to change background color
        }
    }
    
    @ViewBuilder
    func shadowLayer(color: Color, x: CGFloat, y: CGFloat) -> some View {
        Text(text)
            .font(font)
            .foregroundColor(color)
            .offset(x: x, y: y)
            .blur(radius: 1.0)
            .mask(
                Text(text)
                    .font(font)
            )
    }
}

#Preview {
    ZStack {
        EngravedFont(text: "LuxHome")
            .padding(50)
    }
}
