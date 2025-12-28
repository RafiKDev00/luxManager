//
//  ProjectEditForm.swift
//  LuxHome
//
//  Created by RJ Kigner on 12/28/25.
//

import SwiftUI

struct ProjectEditForm: View {
    @Binding var name: String
    @Binding var description: String
    @Binding var dueDate: Date
    @Binding var assignments: [ProjectWorkerAssignment]

    @Environment(LuxHomeModel.self) private var model
    @State private var showingAddWorker = false
    @State private var pendingRemoveAssignment: UUID?

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            basicInfoSection
            dueDateSection
            workersSection
        }
        .sheet(isPresented: $showingAddWorker) {
            WorkerCreationView { newWorker in
                addAssignment(for: newWorker.id)
            }
            .environment(model)
        }
        .alert("Remove Worker?", isPresented: .init(get: { pendingRemoveAssignment != nil }, set: { if !$0 { pendingRemoveAssignment = nil } })) {
            Button("Cancel", role: .cancel) {
                pendingRemoveAssignment = nil
            }
            Button("Remove", role: .destructive) {
                if let id = pendingRemoveAssignment {
                    removeAssignment(id)
                }
                pendingRemoveAssignment = nil
            }
        } message: {
            Text("This will unassign the worker from the project.")
        }
    }

    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Project Details")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.primary)

            groupedFieldStack {
                clearableField("Project Name", text: $name)
                Divider().padding(.leading, 12)
                VStack(spacing: 0) {
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                        .textInputAutocapitalization(.sentences)
                        .tint(.orange)
                        .padding(.vertical, 12)
                        .padding(.leading, 12)
                        .padding(.trailing, 12)
                }
            }
        }
    }

    private var dueDateSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Due Date")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.primary)

            DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                .tint(.orange)
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        }
    }

    private var workersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Assigned Workers")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.primary)

            if assignments.isEmpty {
                Text("No workers assigned")
                    .foregroundStyle(.secondary)
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            } else {
                VStack(spacing: 12) {
                    ForEach($assignments) { $assignment in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(workerName(for: assignment.workerId))
                                    .font(.headline)
                                TextField("Role", text: $assignment.role)
                                    .textFieldStyle(.roundedBorder)
                                    .tint(.orange)
                            }
                            Spacer()
                            Button(role: .destructive) {
                                pendingRemoveAssignment = assignment.id
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundStyle(.red)
                            }
                            .buttonStyle(.borderless)
                        }
                        .padding(16)
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    }
                }
            }

            HStack(spacing: 12) {
                if !availableWorkers.isEmpty {
                    Menu {
                        ForEach(availableWorkers, id: \.id) { worker in
                            Button(worker.name) {
                                addAssignment(for: worker.id)
                            }
                        }
                    } label: {
                        Label("Add Existing", systemImage: "person.fill.badge.plus")
                            .font(.subheadline)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.orange)
                            .clipShape(Capsule())
                    }
                }

                Button {
                    showingAddWorker = true
                } label: {
                    Label("Add New", systemImage: "plus.circle")
                        .font(.subheadline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.orange)
                        .clipShape(Capsule())
                }
            }
        }
    }

    private var availableWorkers: [LuxWorker] {
        let assignedIds = Set(assignments.map(\.workerId))
        return model.workers.filter { !assignedIds.contains($0.id) }
    }

    private func addAssignment(for workerId: UUID) {
        guard !assignments.contains(where: { $0.workerId == workerId }) else { return }
        assignments.append(ProjectWorkerAssignment(workerId: workerId))
    }

    private func removeAssignment(_ id: UUID) {
        assignments.removeAll { $0.id == id }
    }

    private func workerName(for workerId: UUID) -> String {
        model.workers.first(where: { $0.id == workerId })?.name ?? "Unknown Worker"
    }

    @ViewBuilder
    private func clearableField(_ title: String,
                                text: Binding<String>,
                                keyboard: UIKeyboardType = .default,
                                autocap: TextInputAutocapitalization = .sentences) -> some View {
        HStack {
            TextField(title, text: text)
                .textInputAutocapitalization(autocap)
                .keyboardType(keyboard)
                .tint(.orange)
                .padding(.vertical, 12)
                .padding(.leading, 12)
                .padding(.trailing, 4)
            if !text.wrappedValue.isEmpty {
                Button {
                    text.wrappedValue = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.orange)
                        .font(.system(size: 16, weight: .semibold))
                        .padding(.trailing, 8)
                }
                .buttonStyle(.plain)
            }
        }
    }

    @ViewBuilder
    private func groupedFieldStack<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        VStack(spacing: 0, content: content)
            .padding(.horizontal, 2)
            .padding(.vertical, 2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color(.separator), lineWidth: 0.5)
            )
    }
}

#Preview {
    ProjectEditForm(
        name: .constant("Kitchen Remodel"),
        description: .constant("Complete kitchen renovation including new cabinets, countertops, and appliances"),
        dueDate: .constant(Date()),
        assignments: .constant([])
    )
    .padding()
    .background(Color(.systemGroupedBackground))
    .environment(LuxHomeModel.shared)
}
