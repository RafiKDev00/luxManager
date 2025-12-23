//
//  TaskDetailView.swift
//  LuxHome
//
//  Created by RJ Kigner on 12/21/25.
//

import SwiftUI
import PhotosUI

struct TaskDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(LuxHomeModel.self) private var model

    let task: LuxTask

    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedSubtaskId: UUID?
    @State private var showingDeleteAlert = false
    @State private var isEditMode = false

    var subtasks: [LuxSubTask] {
        model.getSubtasks(for: task.id)
    }

    var isPhotoPickerPresented: Binding<Bool> {
        Binding(
            get: { selectedSubtaskId != nil },
            set: { if !$0 { selectedSubtaskId = nil } }
        )
    }

    var body: some View {
        ZStack(alignment: .top) {
            backgroundView

            subtaskListView
        }
        .navigationTitle(task.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isEditMode.toggle()
                } label: {
                    Text(isEditMode ? "Done" : "Edit")
                }
            }

            if isEditMode {
                ToolbarItem(placement: .topBarLeading) {
                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        Text("Delete Task")
                            .foregroundStyle(.red)
                    }
                }
            }
        }
        .alert("Delete Task", isPresented: $showingDeleteAlert) {
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
        .photosPicker(
            isPresented: isPhotoPickerPresented,
            selection: $selectedPhotoItem,
            matching: .images
        )
        .onChange(of: selectedPhotoItem) { _, newItem in
            handlePhotoSelection(newItem)
        }
    }

    private var backgroundView: some View {
        Color(.systemGroupedBackground)
            .ignoresSafeArea()
    }

    private var subtaskListView: some View {
        VStack(spacing: 0) {
            List {
                Section {
                    SubtaskRowView(subtasks: subtasks, isEditMode: isEditMode, onPhotoTap: handlePhotoTapRequest)
                } header: {
                    subtaskSectionHeader
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
    }

    private var subtaskSectionHeader: some View {
        Text("Subtasks")
            .font(.title2)
            .fontWeight(.bold)
            .foregroundStyle(.primary)
            .textCase(nil)
    }

    private func handlePhotoTapRequest(_ subtaskId: UUID) {
        selectedSubtaskId = subtaskId
    }

    private func handlePhotoSelection(_ photoItem: PhotosPickerItem?) {
        guard let photoItem, let subtaskId = selectedSubtaskId else { return }

        Task {
            await uploadPhotoAndCompleteSubtask(photoItem, for: subtaskId)
            clearPhotoSelection()
        }
    }

    private func uploadPhotoAndCompleteSubtask(_ photoItem: PhotosPickerItem, for subtaskId: UUID) async {
        if let data = try? await photoItem.loadTransferable(type: Data.self) {
            model.updateSubtaskPhoto(subtaskId, photoURL: "placeholder://photo")
        }
    }

    private func clearPhotoSelection() {
        selectedPhotoItem = nil
        selectedSubtaskId = nil
    }
}

struct SubtaskRowView: View {
    @Environment(LuxHomeModel.self) private var model
    @State private var subtaskToDelete: UUID?

    let subtasks: [LuxSubTask]
    let isEditMode: Bool
    let onPhotoTap: (UUID) -> Void

    var body: some View {
        ForEach(Array(subtasks.enumerated()), id: \.element.id) { index, subtask in
            subtaskRow(for: subtask, at: index)
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    deleteButton(for: subtask.id)
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

    private func deleteButton(for subtaskId: UUID) -> some View {
        Button(role: .destructive) {
            subtaskToDelete = subtaskId
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }

    private func subtaskRow(for subtask: LuxSubTask, at index: Int) -> some View {
        HStack {
            subtaskInfo(for: subtask)
            Spacer()

            if isEditMode {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.caption)
                        .foregroundStyle(.gray.opacity(0.5))
                    Text("Swipe")
                        .font(.caption2)
                        .foregroundStyle(.gray.opacity(0.6))
                }
                .padding(.trailing, 8)
            }

            subtaskActions(for: subtask)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color(.secondarySystemGroupedBackground))
        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
        .listRowBackground(Color.clear)
        .listRowSeparator(index == subtasks.count - 1 ? .hidden : .visible, edges: .bottom)
        .clipShape(rowShape(for: index))
    }

    private func subtaskInfo(for subtask: LuxSubTask) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(subtask.name)
                .font(.headline)

            Text(subtask.isCompleted ? "Completed" : "Incomplete")
                .font(.caption)
                .foregroundStyle(subtask.isCompleted ? .orange : .gray)
        }
    }

    @ViewBuilder
    private func subtaskActions(for subtask: LuxSubTask) -> some View {
        if isEditMode {
            Button {
                subtaskToDelete = subtask.id
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(.red)
            }
            .buttonStyle(.plain)
        } else {
            cameraOrCheckmarkButton(for: subtask)

            if !subtask.isCompleted {
                manualCompletionButton(for: subtask)
            }
        }
    }

    private func cameraOrCheckmarkButton(for subtask: LuxSubTask) -> some View {
        Button {
            handleCameraButtonTap(for: subtask)
        } label: {
            Image(systemName: subtask.isCompleted ? "checkmark.circle.fill" : "camera.fill")
                .font(.system(size: 24))
                .foregroundStyle(subtask.isCompleted ? .orange : .gray)
        }
        .buttonStyle(.plain)
    }

    private func manualCompletionButton(for subtask: LuxSubTask) -> some View {
        Button {
            model.toggleSubtaskCompletion(subtask.id)
        } label: {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 24))
                .foregroundStyle(.gray)
        }
        .buttonStyle(.plain)
    }

    private func rowShape(for index: Int) -> UnevenRoundedRectangle {
        UnevenRoundedRectangle(
            topLeadingRadius: index == 0 ? 12 : 0,
            bottomLeadingRadius: index == subtasks.count - 1 ? 12 : 0,
            bottomTrailingRadius: index == subtasks.count - 1 ? 12 : 0,
            topTrailingRadius: index == 0 ? 12 : 0,
            style: .continuous
        )
    }

    private func handleCameraButtonTap(for subtask: LuxSubTask) {
        if subtask.isCompleted {
            model.toggleSubtaskCompletion(subtask.id)
        } else {
            onPhotoTap(subtask.id)
        }
    }
}

#Preview {
    NavigationStack {
        TaskDetailView(task: LuxHomeModel.sampleTasks[0])
            .environment(LuxHomeModel.shared)
    }
}
