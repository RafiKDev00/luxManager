//
//  StatusHeaderView.swift
//  LuxHome
//
//  Created by RJ Kigner on 12/21/25.
//

import SwiftUI

struct StatusHeaderView: View {
    var body: some View {
        EngravedFont(text: "Regular Work", font: .system(size: 40, weight: .bold))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    StatusHeaderView()
}
