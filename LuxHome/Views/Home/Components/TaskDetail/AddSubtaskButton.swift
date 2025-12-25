//
//  AddSubtaskButton.swift
//  LuxHome
//
//  Created by RJ Kigner on 12/24/25.
//

import SwiftUI

struct AddSubtaskButton: View {
    let action: () -> Void
    let isLast: Bool

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Add Subtask")
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    Text("Tap to add")
                        .font(.caption)
                        .foregroundStyle(.gray)
                }

                Spacer()

                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(.white, .orange)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color(.secondarySystemGroupedBackground))
        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: 0,
                bottomLeadingRadius: isLast ? 12 : 0,
                bottomTrailingRadius: isLast ? 12 : 0,
                topTrailingRadius: 0,
                style: .continuous
            )
        )
    }
}
