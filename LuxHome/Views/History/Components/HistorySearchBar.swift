//
//  HistorySearchBar.swift
//  LuxHome
//
//  Created by RJ Kigner on 12/23/25.
//

import SwiftUI

struct HistorySearchBar: View {
    @Binding var searchText: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
                .padding(.leading, 16)

            TextField("Search by name or date", text: $searchText)
                .textFieldStyle(.plain)
                .autocorrectionDisabled()

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                        .tint(.orange)
                }
                .padding(.trailing, 16)
            }
        }
        .padding(.vertical, 12)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
        .background(Color.clear)
    }
}

#Preview("Empty") {
    @Previewable @State var searchText = ""
    HistorySearchBar(searchText: $searchText)
}

#Preview("With Text") {
    @Previewable @State var searchText = "Kitchen"
    HistorySearchBar(searchText: $searchText)
}
