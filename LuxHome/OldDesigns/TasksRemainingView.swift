//
//  TasksRemainingView.swift
//  LuxHome
//
//  Created by RJ Kigner on 12/18/25.
//

import SwiftUI

struct TasksRemainingView: View {
    let completedCount: Int
    let totalCount: Int

    var remainingCount: Int {
        totalCount - completedCount
    }

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "checklist")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text("\(remainingCount) of \(totalCount) tasks remaining")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        TasksRemainingView(completedCount: 2, totalCount: 5)
        TasksRemainingView(completedCount: 0, totalCount: 10)
        TasksRemainingView(completedCount: 8, totalCount: 8)
    }
    .padding()
}
