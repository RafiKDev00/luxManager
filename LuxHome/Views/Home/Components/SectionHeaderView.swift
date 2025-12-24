//
//  SectionHeaderView.swift
//  LuxHome
//
//  Created by RJ Kigner on 12/21/25.
//

import SwiftUI

struct SectionHeaderView: View {
    let title: String
    var color: Color = .primary

    var body: some View {
        HStack {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(color)
                .textCase(nil)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.orange.opacity(0.2))
        .cornerRadius(8)
    }
    
}
