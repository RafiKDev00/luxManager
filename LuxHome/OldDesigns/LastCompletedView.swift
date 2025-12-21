//
//  LastCompletedView.swift
//  LuxHome
//
//  Created by RJ Kigner on 12/18/25.
//

import SwiftUI

struct LastCompletedView: View {
    let date: Date?

    var body: some View {
        HStack(spacing: 4) {
            Text("Last Completed:")
                .font(.caption)
                .foregroundStyle(.secondary)

            if let date = date {
                Text(date, style: .date)
                    .font(.caption)
                    .foregroundStyle(.primary)
            } else {
                Text("Never")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        LastCompletedView(date: Date())
        LastCompletedView(date: Date().addingTimeInterval(-86400 * 5))
        LastCompletedView(date: nil)
    }
    .padding()
}
