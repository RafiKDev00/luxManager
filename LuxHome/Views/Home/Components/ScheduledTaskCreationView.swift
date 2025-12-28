//
//  ScheduledTaskCreationView.swift
//  LuxHome
//
//  Created by RJ Kigner on 12/21/25.
//

import SwiftUI

struct ScheduledTaskCreationView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(LuxHomeModel.self) private var model

    @State private var taskName: String = ""
    @State private var recurringInterval: Int = 1
    @State private var recurringUnit: RecurringInterval = .weeks
    @State private var subtasks: [SubtaskItem] = []

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Task Name", text: $taskName)
                        .font(.headline)
                } header: {
                    Text("Task Details")
                }

                Section {
                    RecurringIntervalPicker(
                        interval: $recurringInterval,
                        unit: $recurringUnit
                    )
                } header: {
                    Text("Schedule")
                }

                Section {
                    ForEach($subtasks) { $subtask in
                        TextField("Subtask", text: $subtask.name)
                    }
                    .onDelete(perform: deleteSubtask)

                    Button {
                        addSubtask()
                    } label: {
                        Label("Add Subtask", systemImage: "plus.circle.fill")
                            .foregroundStyle(.orange)
                    }
                } header: {
                    Text("Subtasks")
                }
            }
            .safeAreaBar(edge: .top, spacing: 0) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .buttonStyle(IconButtonStyle(type: .close))
                    .padding(.leading, 16)

                    Spacer()
                    
                   Text("New Task")
                        .font(.system(size: 24, weight: .bold))

                    Spacer()

                    Button {
                        saveTask()
                    } label: {
                        Image(systemName: "checkmark")
                    }
                    .buttonStyle(IconButtonStyle(type: .check))
                    .disabled(taskName.isEmpty)
                    .opacity(taskName.isEmpty ? 0.8 : 1.0)
                    .padding(.trailing, 16)
                }
                .padding(.top, 8)
                .padding(.bottom, 8)
                .background(Color.clear)
            }
        }
    }

    private func addSubtask() {
        guard subtasks.allSatisfy({ !$0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) else {
            return
        }
        subtasks.append(SubtaskItem(name: ""))
    }

    private func deleteSubtask(at offsets: IndexSet) {
        subtasks.remove(atOffsets: offsets)
    }

    private func saveTask() {
        let subtaskNames = subtasks.map { $0.name }.filter { !$0.isEmpty }
        model.createTask(
            name: taskName,
            isRecurring: true,
            recurringInterval: recurringInterval,
            recurringUnit: recurringUnit,
            subtaskNames: subtaskNames
        )
        dismiss()
    }
}

enum DayOfWeek: String, CaseIterable, Identifiable {
    case monday = "Monday"
    case tuesday = "Tuesday"
    case wednesday = "Wednesday"
    case thursday = "Thursday"
    case friday = "Friday"
    case saturday = "Saturday"
    case sunday = "Sunday"

    var id: String { rawValue }
}

struct SubtaskItem: Identifiable {
    let id = UUID()
    var name: String
}

#Preview {
    @Previewable @State var showingSheet = true

    Color.clear
        .sheet(isPresented: $showingSheet) {
            ScheduledTaskCreationView()
                .environment(LuxHomeModel.shared)
        }
}
