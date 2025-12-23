//
//  WeeklySummaryStrip.swift
//  LuxHome
//
//  Created by RJ Kigner on 12/23/25.
//

import SwiftUI

struct WeeklySummaryStrip: View {
    @Environment(LuxHomeModel.self) private var model

    var totalTasks: Int {
        model.incompleteTasks.count
    }

    var overdueTasks: Int {
        model.incompleteTasks.filter { isOverdue($0) }.count
    }

    var isAllClear: Bool {
        totalTasks == 0
    }

    var body: some View {
        HStack(spacing: 8) {
            if isAllClear {
                allClearContent
            } else {
                summaryContent
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private var allClearContent: some View {
        HStack(spacing: 6) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
                .font(.system(size: 16))

            Text("All set for the week")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
        }
    }

    private var summaryContent: some View {
        HStack(spacing: 4) {
            Text("This week")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)

            Text("·")
                .foregroundStyle(.secondary.opacity(0.5))

            Text("\(totalTasks) \(totalTasks == 1 ? "task" : "tasks")")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)

            if overdueTasks > 0 {
                Text("·")
                    .foregroundStyle(.secondary.opacity(0.5))

                Text("\(overdueTasks) overdue")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.pink)
            }
        }
    }

    private var backgroundColor: Color {
        if isAllClear {
            return Color.green.opacity(0.1)
        } else if overdueTasks > 0 {
            return Color.pink.opacity(0.1)
        } else {
            return Color.orange.opacity(0.1)
        }
    }

    private func isOverdue(_ task: LuxTask) -> Bool {
        let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!

        if let lastCompleted = task.lastCompletedDate {
            return lastCompleted < oneWeekAgo
        } else {
            return task.createdAt < oneWeekAgo
        }
    }
}

#Preview("With Tasks") {
    WeeklySummaryStrip()
        .environment(LuxHomeModel.shared)
}

#Preview("All Clear") {
    let model = LuxHomeModel.shared
    model.tasks = []
    return WeeklySummaryStrip()
        .environment(model)
}
