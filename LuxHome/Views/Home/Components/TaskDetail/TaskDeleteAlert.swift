//
//  TaskDeleteAlert.swift
//  LuxHome
//
//  Created by RJ Kigner on 12/24/25.
//

import SwiftUI

struct TaskDeleteAlert: ViewModifier {
    @Environment(\.dismiss) private var dismiss
    @Environment(LuxHomeModel.self) private var model

    let task: LuxTask
    @Binding var isPresented: Bool
    @Binding var isEditMode: Bool

    func body(content: Content) -> some View {
        content
            .alert("Delete Task", isPresented: $isPresented) {
                Button("Cancel", role: .cancel) {
                    isEditMode = false
                }
                Button("Delete", role: .destructive) {
                    model.deleteTask(task.id)
                    dismiss()
                }
            } message: {
                Text("Are you sure you want to delete this task? This action cannot be undone.")
            }
    }
}

extension View {
    func taskDeleteAlert(
        task: LuxTask,
        isPresented: Binding<Bool>,
        isEditMode: Binding<Bool>
    ) -> some View {
        modifier(TaskDeleteAlert(
            task: task,
            isPresented: isPresented,
            isEditMode: isEditMode
        ))
    }
}
