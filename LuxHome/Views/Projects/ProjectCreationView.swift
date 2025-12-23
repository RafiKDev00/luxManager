//
//  ProjectCreationView.swift
//  LuxHome
//
//  Created by RJ Kigner on 12/21/25.
//

import SwiftUI

struct ProjectCreationView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(LuxHomeModel.self) private var model

    @State private var projectName: String = ""
    @State private var description: String = ""
    @State private var dueDate: Date = Date()
    @State private var nextStep: String = ""
    @State private var assignedWorkers: [ProjectWorkerAssignment] = []
    @State private var showingAddWorker = false

    var body: some View {
        NavigationStack {
            Form {
                projectDetailsSection
                schedulingSection
                nextStepSection
                workersSection
            }
            .safeAreaBar(edge: .top, spacing: 0) {
                topBar
            }
        }
    }

    private var projectDetailsSection: some View {
        Section {
            TextField("Project Name", text: $projectName)
                .font(.headline)

            TextField("Description", text: $description, axis: .vertical)
                .lineLimit(3...6)
        } header: {
            Text("Project Details")
        }
    }

    private var schedulingSection: some View {
        Section {
            DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                .tint(.orange)
        } header: {
            Text("Timeline")
        }
    }

    private var nextStepSection: some View {
        Section {
            TextField("Next Step", text: $nextStep, axis: .vertical)
                .lineLimit(2...4)
        } header: {
            Text("Next Step (Optional)")
        }
    }

    private var workersSection: some View {
        Section {
            if assignedWorkers.isEmpty {
                Text("No workers assigned")
                    .foregroundStyle(.secondary)
            } else {
                ForEach($assignedWorkers) { $assignment in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(workerName(for: assignment.workerId))
                                .font(.headline)
                            TextField("Role", text: $assignment.role)
                                .textFieldStyle(.roundedBorder)
                        }
                        Spacer()
                        Button(role: .destructive) {
                            removeAssignment(assignment.id)
                        } label: {
                            Image(systemName: "trash")
                        }
                        .buttonStyle(.borderless)
                    }
                }
            }

            if !availableWorkers.isEmpty {
                Menu {
                    ForEach(availableWorkers, id: \.id) { worker in
                        Button(worker.name) {
                            addAssignment(for: worker.id)
                        }
                    }
                } label: {
                    Label("Add Existing Worker", systemImage: "person.fill.badge.plus")
                }
            }

            Button {
                showingAddWorker = true
            } label: {
                Label("Add New Worker", systemImage: "plus.circle")
            }
        } header: {
            Text("Workers")
        }
        .sheet(isPresented: $showingAddWorker) {
            AddWorkerView()
        }
    }

    private var topBar: some View {
        HStack {
            closeButton
            Spacer()
            titleText
            Spacer()
            saveButton
        }
        .padding(.top, 8)
        .padding(.bottom, 8)
        .background(Color.clear)
    }

    private var closeButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark")
        }
        .buttonStyle(IconButtonStyle(type: .close))
        .padding(.leading, 16)
    }

    private var titleText: some View {
        Text("New Project")
            .font(.system(size: 24, weight: .bold))
    }

    private var saveButton: some View {
        Button {
            saveProject()
        } label: {
            Image(systemName: "checkmark")
        }
        .buttonStyle(IconButtonStyle(type: .check))
        .disabled(projectName.isEmpty || description.isEmpty)
        .opacity(projectName.isEmpty || description.isEmpty ? 0.8 : 1.0)
        .padding(.trailing, 16)
    }

    private func saveProject() {
        model.createProject(
            name: projectName,
            description: description,
            dueDate: dueDate,
            nextStep: nextStep,
            assignedWorkers: assignedWorkers
        )
        dismiss()
    }

    private var availableWorkers: [LuxWorker] {
        let assignedIds = Set(assignedWorkers.map(\.workerId))
        return model.workers.filter { !assignedIds.contains($0.id) }
    }

    private func addAssignment(for workerId: UUID) {
        guard !assignedWorkers.contains(where: { $0.workerId == workerId }) else { return }
        assignedWorkers.append(ProjectWorkerAssignment(workerId: workerId))
    }

    private func removeAssignment(_ id: UUID) {
        assignedWorkers.removeAll { $0.id == id }
    }

    private func workerName(for workerId: UUID) -> String {
        model.workers.first(where: { $0.id == workerId })?.name ?? "Unknown Worker"
    }
}

#Preview {
    @Previewable @State var showingSheet = true

    Color.clear
        .sheet(isPresented: $showingSheet) {
            ProjectCreationView()
                .environment(LuxHomeModel.shared)
        }
}
