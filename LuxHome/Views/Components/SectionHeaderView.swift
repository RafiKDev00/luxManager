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
        Text(title)
            .font(.title2)
            .fontWeight(.bold)
            .foregroundStyle(color)
            .textCase(nil)
    }
}
