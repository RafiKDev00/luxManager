//
//  NewSubtaskRow.swift
//  LuxHome
//
//  Created by RJ Kigner on 12/24/25.
//

import SwiftUI

struct NewSubtaskRow: View {
    @Binding var text: String
    @FocusState.Binding var isFocused: Bool
    let onCommit: () -> Void
    let onCancel: () -> Void
    let isLast: Bool

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                TextField("Subtask name", text: $text)
                    .font(.headline)
                    .focused($isFocused)
                    .submitLabel(.done)
                    .onSubmit(onCommit)

                Text("Incomplete")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }

            Spacer()

            Button(action: onCommit) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(.white, .blue)
            }
            .buttonStyle(.plain)

            Button(action: onCancel) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(.white, .orange)
                    .rotationEffect(.degrees(45))
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color(.secondarySystemGroupedBackground))
        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
        .listRowBackground(Color.clear)
        .listRowSeparator(isLast ? .hidden : .visible, edges: .bottom)
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
