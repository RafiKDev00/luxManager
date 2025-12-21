//
//  TaskObject.swift
//  LuxHome
//
//  Created by RJ  Kigner on 12/18/25.
//

import SwiftUI

struct TaskObject: View {
    var taskName: String = "This is a Sample Task Name that we will use to"
    var status: String = "Not Started"
    var taskDescription: String = "Do all the things that are that are required for this task. It may take a few days or so, but that's alright! You know, these things do take type. And the key is to be patient"
    var lastCompletedDate: Date?
    var completedSubtasks: Int = 0
    var totalSubtasks: Int = 1
    @Binding var isCompleted: Bool

    var progressValue: Double {
        guard totalSubtasks > 0 else { return 0 }
        return Double(completedSubtasks) / Double(totalSubtasks)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 16) {
                TaskTitle
                Spacer()
            }
                TasksRemaining

        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: 150, alignment: .topLeading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 32, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }
    
    var TaskTitle: some View {
        Text(taskName.isEmpty ? "Task Name" : taskName)
            .font(.headline)
            .foregroundColor(taskName.isEmpty ? .secondary : .primary)
            .lineLimit(2)
            .truncationMode(.tail)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    var TasksRemaining: some View {
        HStack(spacing: 12) {
            TasksRemainingView(completedCount: completedSubtasks, totalCount: totalSubtasks)

            Spacer()

            Gauge(value: progressValue, in: 0...1) {
                EmptyView()
            }
            .gaugeStyle(.accessoryCircular)
            .tint(.blue)
            .frame(width: 32, height: 32)
        }
    }
}

#Preview("To Do") {
    @Previewable @State var isCompleted = false
    TaskObject(taskName: "Install New Kitchen Cabinets", status: "To Do", lastCompletedDate: nil, completedSubtasks: 0, totalSubtasks: 8, isCompleted: $isCompleted)
        .padding()
}

#Preview("Active") {
    @Previewable @State var isCompleted = false
    TaskObject(taskName: "Paint Living Room Walls", status: "Active", lastCompletedDate: Date().addingTimeInterval(-86400 * 5), completedSubtasks: 3, totalSubtasks: 6, isCompleted: $isCompleted)
        .padding()
}

#Preview("Overdue") {
    @Previewable @State var isCompleted = false
    TaskObject(taskName: "Fix leaking Bathroom Faucet", status: "Overdue", lastCompletedDate: Date().addingTimeInterval(-86400 * 30), completedSubtasks: 1, totalSubtasks: 4, isCompleted: $isCompleted)
        .padding()
}

#Preview("Waiting") {
    @Previewable @State var isCompleted = false
    TaskObject(taskName: "Schedule Electrical Inspection", status: "Waiting", lastCompletedDate: Date(), completedSubtasks: 5, totalSubtasks: 5, isCompleted: $isCompleted)
        .padding()
}


//
