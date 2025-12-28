//
//  TaskDetailView.swift
//  LuxHome
//
//  Created by RJ Kigner on 12/21/25.
//

import SwiftUI
import PhotosUI

struct TaskDetailView: View {
    @Environment(LuxHomeModel.self) private var model

    let task: LuxTask

    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedSubtaskId: UUID?
    @State private var showingDeleteAlert = false
    @State private var isEditMode = false
    @State private var isAddingSubtask = false
    @State private var newSubtaskName = ""
    @FocusState private var isNewSubtaskFocused: Bool

    @State private var isEditingTaskName = false
    @State private var draftTaskName = ""
    @FocusState private var isTaskNameFocused: Bool

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
        subtaskList
            .background(Color(.systemGroupedBackground))
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .top) {
                taskTitleHeader
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 12)
                    .background(Color(.systemGroupedBackground))
            }
        .toolbar {
            TaskToolbar(
                isEditMode: $isEditMode,
                onDeleteTap: { showingDeleteAlert = true }
            )
        }
        .taskDeleteAlert(
            task: task,
            isPresented: $showingDeleteAlert,
            isEditMode: $isEditMode
        )
        .photosPicker(
            isPresented: isPhotoPickerPresented,
            selection: $selectedPhotoItem,
            matching: .images
        )
        .onChange(of: selectedPhotoItem) { _, newItem in
            handlePhotoSelection(newItem)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private var taskTitleHeader: some View {
        HStack(alignment: .center, spacing: 8) {
            if isEditingTaskName {
                TextField("Task name", text: $draftTaskName)
                    .font(.largeTitle.weight(.bold))
                    .tint(.orange)
                    .focused($isTaskNameFocused)
                    .onSubmit {
                        saveTaskName()
                    }
                Button {
                    saveTaskName()
                } label: {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.blue)
                }
                .buttonStyle(.plain)
            } else {
                Text(task.name)
                    .font(.largeTitle.weight(.bold))
                Button {
                    startEditingTaskName()
                } label: {
                    Image(systemName: "pencil")
                        .font(.system(size: 20))
                        .foregroundStyle(.orange)
                }
                .buttonStyle(.plain)
            }
            Spacer()
        }
    }

    private var subtaskList: some View {
        List {
            Section {
                SubtaskListView(
                    subtasks: subtasks,
                    isEditMode: isEditMode,
                    hasAddButton: !isEditMode || isAddingSubtask,
                    onPhotoTap: { selectedSubtaskId = $0 }
                )

                if isAddingSubtask {
                    NewSubtaskRow(
                        text: $newSubtaskName,
                        isFocused: $isNewSubtaskFocused,
                        onCommit: createSubtask,
                        onCancel: cancelAddingSubtask,
                        isLast: true
                    )
                } else if !isEditMode {
                    AddSubtaskButton(
                        action: {
                            isAddingSubtask = true
                            isNewSubtaskFocused = true
                        },
                        isLast: true
                    )
                }
            } header: {
                Text("Subtasks")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                    .textCase(nil)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
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

    private func createSubtask() {
        let trimmed = newSubtaskName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let newSubtask = LuxSubTask(
            name: trimmed,
            isCompleted: false,
            taskId: task.id
        )
        model.addSubtask(newSubtask)

        isNewSubtaskFocused = false
        newSubtaskName = ""
        isAddingSubtask = false
    }

    private func cancelAddingSubtask() {
        isNewSubtaskFocused = false
        newSubtaskName = ""
        isAddingSubtask = false
    }

    private func startEditingTaskName() {
        draftTaskName = task.name
        isEditingTaskName = true
        isTaskNameFocused = true
    }

    private func saveTaskName() {
        let trimmed = draftTaskName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            isEditingTaskName = false
            return
        }
        model.updateTaskName(task.id, name: trimmed)
        isEditingTaskName = false
        isTaskNameFocused = false
    }
}

#Preview {
    NavigationStack {
        TaskDetailView(task: LuxHomeModel.sampleTasks[0])
            .environment(LuxHomeModel.shared)
    }
}
