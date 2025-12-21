//
//  CheckmarkButton.swift
//  LuxHome
//
//  Created by RJ Kigner on 12/18/25.
//

import SwiftUI

struct CheckmarkButton: View {
    @Binding var isCompleted: Bool

    var body: some View {
        Toggle(isOn: $isCompleted) {
            Image(systemName: isCompleted ? "checkmark.square.fill" : "square")
                .font(.system(size: 24))
                .foregroundStyle(isCompleted ? .blue : .gray)
        }
        .toggleStyle(.button)
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 20) {
        CheckmarkButton(isCompleted: .constant(false))
        CheckmarkButton(isCompleted: .constant(true))
    }
    .padding()
}
