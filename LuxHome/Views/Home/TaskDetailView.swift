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
                    SubtaskRowView(subtasks: subtasks, onPhotoTap: handlePhotoTapRequest)
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

    let subtasks: [LuxSubTask]
    let onPhotoTap: (UUID) -> Void

    var body: some View {
        ForEach(Array(subtasks.enumerated()), id: \.element.id) { index, subtask in
            subtaskRow(for: subtask, at: index)
        }
    }

    private func subtaskRow(for subtask: LuxSubTask, at index: Int) -> some View {
        HStack {
            subtaskInfo(for: subtask)
            Spacer()
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
                .foregroundStyle(subtask.isCompleted ? .pink : .gray)
        }
    }

    @ViewBuilder
    private func subtaskActions(for subtask: LuxSubTask) -> some View {
        cameraOrCheckmarkButton(for: subtask)

        if !subtask.isCompleted {
            manualCompletionButton(for: subtask)
        }
    }

    private func cameraOrCheckmarkButton(for subtask: LuxSubTask) -> some View {
        Button {
            handleCameraButtonTap(for: subtask)
        } label: {
            Image(systemName: subtask.isCompleted ? "checkmark.circle.fill" : "camera.fill")
                .font(.system(size: 24))
                .foregroundStyle(subtask.isCompleted ? .pink : .gray)
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
