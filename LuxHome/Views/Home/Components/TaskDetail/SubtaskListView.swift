//
//  SubtaskListView.swift
//  LuxHome
//
//  Created by RJ Kigner on 12/24/25.
//

import SwiftUI

struct SubtaskListView: View {
    @Environment(LuxHomeModel.self) private var model
    @State private var subtaskToDelete: UUID?

    let subtasks: [LuxSubTask]
    let isEditMode: Bool
    let hasAddButton: Bool
    let onPhotoTap: (UUID) -> Void

    var body: some View {
        ForEach(Array(subtasks.enumerated()), id: \.element.id) { index, subtask in
            SubtaskRow(
                subtask: subtask,
                index: index,
                totalCount: subtasks.count,
                isEditMode: isEditMode,
                isLast: !hasAddButton && index == subtasks.count - 1,
                onPhotoTap: onPhotoTap,
                onDelete: handleDelete
            )
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                deleteSwipeButton(for: subtask.id)
            }
        }
        .alert("Delete Subtask", isPresented: Binding(
            get: { subtaskToDelete != nil },
            set: { if !$0 { subtaskToDelete = nil } }
        )) {
            Button("Cancel", role: .cancel) {
                subtaskToDelete = nil
            }
            Button("Delete", role: .destructive) {
                if let id = subtaskToDelete {
                    model.deleteSubtask(id)
                    subtaskToDelete = nil
                }
            }
        } message: {
            Text("Are you sure you want to delete this subtask?")
        }
    }

    private func deleteSwipeButton(for subtaskId: UUID) -> some View {
        Button(role: .destructive) {
            subtaskToDelete = subtaskId
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }

    private func handleDelete(_ subtaskId: UUID) {
        subtaskToDelete = subtaskId
    }
}
