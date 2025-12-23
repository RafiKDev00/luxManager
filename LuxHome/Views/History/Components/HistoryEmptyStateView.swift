//
//  HistoryEmptyStateView.swift
//  LuxHome
//
//  Created by RJ Kigner on 12/23/25.
//

import SwiftUI

struct HistoryEmptyStateView: View {
    let searchText: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 60))
                .foregroundStyle(.gray)
            Text(searchText.isEmpty ? "No history yet" : "No results found")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview("Empty State") {
    HistoryEmptyStateView(searchText: "")
}

#Preview("No Results") {
    HistoryEmptyStateView(searchText: "search query")
}
