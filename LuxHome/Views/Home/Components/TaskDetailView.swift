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
            get: {
                let isPresented = selectedSubtaskId != nil
                print("[TaskDetail] PhotoPicker isPresented: \(isPresented), selectedSubtaskId: \(String(describing: selectedSubtaskId))")
                return isPresented
            },
            set: { newValue in
                print("[TaskDetail] PhotoPicker dismissed, newValue: \(newValue)")
                // Don't clear selectedSubtaskId here - let onChange handle it after upload completes
            }
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
            matching: .images,
            photoLibrary: .shared()
        )
        .onChange(of: selectedPhotoItem) { oldValue, newItem in
            print("[TaskDetail] onChange triggered - oldValue: \(String(describing: oldValue)), newItem: \(String(describing: newItem))")

            // Capture the photo item and subtask ID immediately before picker clears them
            guard let photoItem = newItem, let subtaskId = selectedSubtaskId else {
                print("[TaskDetail] onChange - photoItem or subtaskId is nil")
                return
            }

            print("[TaskDetail] onChange - starting upload for subtask: \(subtaskId)")

            // Clear picker immediately (non-blocking)
            clearPhotoSelection()

            // Upload in background
            Task {
                await uploadPhotoAndCompleteSubtask(photoItem, for: subtaskId)
            }
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
                    onPhotoTap: { subtaskId in
                        print("[TaskDetail] Camera tapped for subtask: \(subtaskId)")
                        selectedSubtaskId = subtaskId
                    }
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

    private func uploadPhotoAndCompleteSubtask(_ photoItem: PhotosPickerItem, for subtaskId: UUID) async {
        print("[TaskDetail] Starting photo upload for subtask: \(subtaskId)")

        guard let data = try? await photoItem.loadTransferable(type: Data.self) else {
            print("[TaskDetail] Failed to load photo data")
            return
        }

        print("[TaskDetail] Photo data loaded, size: \(data.count) bytes")

        do {
            // Upload to Supabase Storage
            let filename = "\(UUID().uuidString).jpg"
            let photoURL = try await model.uploadPhoto(data, filename: filename)
            print("[TaskDetail] ✅ Upload successful: \(photoURL)")

            // Save Supabase URL to database
            await MainActor.run {
                model.addPhotoToSubtask(subtaskId, photoURL: photoURL)
                print("[TaskDetail] Photo added to model for subtask: \(subtaskId)")
            }
        } catch {
            print("[TaskDetail] ❌ Upload failed: \(error)")
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
