//
//  TabHeaderView.swift
//  LuxHome
//
//  Created by RJ Kigner on 12/24/25.
//

import SwiftUI

struct TabHeaderView: View {
    let title: String
    var onEllipsis: (() -> Void)? = nil

    var body: some View {
        HStack {
            EngravedFont(text: title, font: .system(size: 40, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)

            if let onEllipsis {
                Button(action: onEllipsis) {
                    Image(systemName: "ellipsis")
                }
                .buttonStyle(IconButtonStyle(type: .ellipsis))
                .padding(.trailing, 16)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.orange))
    }
}

#Preview {
    TabHeaderView(title: "Header") { }
}
