//
//  WorkersEmptyStateView.swift
//  LuxHome
//
//  Created by RJ Kigner on 12/29/25.
//

import SwiftUI

struct WorkersEmptyStateView: View {
    let isFiltered: Bool

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.2")
                .font(.system(size: 60))
                .foregroundStyle(.gray)
            Text(isFiltered ? "No workers for current projects" : "No workers yet")
                .font(.title3)
                .foregroundStyle(.secondary)
            if !isFiltered {
                Text("Tap + to add your first worker")
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview("Empty") {
    WorkersEmptyStateView(isFiltered: false)
}

#Preview("Filtered") {
    WorkersEmptyStateView(isFiltered: true)
}
