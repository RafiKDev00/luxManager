//
//  MaintenanceTaskRow.swift
//  LuxHome
//
//  Created by RJ Kigner on 12/28/25.
//

import SwiftUI

struct MaintenanceTaskRow: View {
    let task: LuxTask
    let isLast: Bool

    var body: some View {
        NavigationLink(destination: TaskDetailView(task: task).environment(LuxHomeModel.shared)) {
            HStack(spacing: 12) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundStyle(.orange)

                VStack(alignment: .leading, spacing: 4) {
                    Text(task.name)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    if let dueDate = task.nextDueDate {
                        Text(formattedDate(dueDate))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                Text(task.isCompleted ? "Completed" : task.dueDateDescription())
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)

        if !isLast {
            Divider()
                .padding(.leading, 48)
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: date)
    }
}
