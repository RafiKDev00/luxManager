//
//  TaskRowView.swift
//  LuxHome
//
//  Created by RJ Kigner on 12/21/25.
//

import SwiftUI

struct TaskRowView: View {
    let tasks: [LuxTask]

    var body: some View {
        ForEach(Array(tasks.enumerated()), id: \.element.id) { index, task in
            NavigationLink(destination: TaskDetailView(task: task)) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(task.name)
                            .font(.headline)
                        Text(task.status)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(task.isCompleted ? .pink : .gray)
                }
            }
            .buttonStyle(.plain)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color(.secondarySystemGroupedBackground))
            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
            .listRowBackground(Color.clear)
            .listRowSeparator(index == tasks.count - 1 ? .hidden : .visible, edges: .bottom)
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: index == 0 ? 12 : 0,
                    bottomLeadingRadius: index == tasks.count - 1 ? 12 : 0,
                    bottomTrailingRadius: index == tasks.count - 1 ? 12 : 0,
                    topTrailingRadius: index == 0 ? 12 : 0,
                    style: .continuous
                )
            )
        }
    }
}
