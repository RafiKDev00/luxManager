//
//  TaskView.swift
//  LuxHome
//
//  Created by RJ  Kigner on 12/18/25.
//

import SwiftUI

struct TaskView: View {
    @State private var tasks: [LuxTask] = LuxHomeModel.sampleTasks

    var body: some View {
        NavigationStack {
            taskScrollArea
        }
    }

    var taskScrollArea: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach($tasks) { $task in
                    NavigationLink(destination: SubTaskView(task: $task)) {
                        TaskObject(
                            taskName: task.name,
                            status: task.status,
                            taskDescription: task.description,
                            lastCompletedDate: task.lastCompletedDate,
                            completedSubtasks: task.completedSubtasks,
                            totalSubtasks: task.totalSubtasks,
                            isCompleted: $task.isCompleted
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 100)
        }
        .scrollIndicators(.hidden)
    }
}

#Preview {
    TaskView()
}
