//
//  ProjectDetailView.swift
//  LuxHome
//
//  Created by RJ Kigner on 12/21/25.
//

import SwiftUI
import Kingfisher
import PhotosUI

struct ProjectDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(LuxHomeModel.self) private var model

    let projectId: UUID
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showingProgressLogEntry = false
    @State private var showingDeleteAlert = false
    @State private var showingAddWorker = false
    @State private var assignments: [ProjectWorkerAssignment] = []
    @State private var pendingRemoveAssignment: UUID?
    @State private var draftName: String = ""
    @State private var draftDescription: String = ""
    @State private var isEditingName = false
    @State private var isEditingDescription = false
    @State private var isEditingNextStep = false
    @State private var draftNextStep: String = ""
    @State private var roleEditing: Set<UUID> = []
    @State private var pendingPhotoToDelete: String?
    @State private var pendingLogToDelete: UUID?
    @State private var editingLogId: UUID?
    @State private var draftLogText: String = ""
    @State private var addingPhotoToLogId: UUID?
    @State private var selectedLogPhotoItem: PhotosPickerItem?
    @FocusState private var isNextStepFocused: Bool

    private var project: LuxProject {
        model.projects.first(where: { $0.id == projectId }) ?? LuxProject(
            id: projectId,
            name: "Unknown",
            description: "",
            dueDate: Date()
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                detailsSection
                statusSection
                nextStepSection
                assignedWorkersSection
                photoGallerySection
                progressLogSection
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Color(.systemGroupedBackground))
        .navigationTitle(draftName.isEmpty ? project.name : draftName)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(role: .destructive) {
                    showingDeleteAlert = true
                } label: {
                    Image(systemName: "trash")
                        .foregroundStyle(.red)
                }
            }
        }
        .alert("Delete Project", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                model.deleteProject(projectId)
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete this project? This action cannot be undone.")
        }
        .onChange(of: selectedPhotoItem) { _, newItem in
            handlePhotoSelection(newItem)
        }
        .sheet(isPresented: $showingProgressLogEntry) {
            ProgressLogEntryView(projectId: projectId)
                .environment(model)
        }
        .sheet(isPresented: $showingAddWorker) {
            WorkerCreationView { newWorker in
                addAssignment(for: newWorker.id)
            }
            .environment(model)
        }
        .onAppear {
            assignments = project.assignedWorkers
            draftName = project.name
            draftDescription = project.description
            draftNextStep = project.nextStep
        }
        .onChange(of: assignments) { _, newValue in
            model.updateProjectAssignments(projectId, assignments: newValue)
        }
    }

    private var assignedWorkersSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("Workers")
            if assignments.isEmpty {
                Text("No workers assigned")
                    .foregroundStyle(.secondary)
            } else {
                ForEach($assignments) { $assignment in
                    workerRow(assignment: $assignment)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                pendingRemoveAssignment = assignment.id
                            } label: {
                                Label("Remove", systemImage: "trash")
                            }
                        }
                }
            }
            HStack{
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
                
                Spacer()

                Button {
                    showingAddWorker = true
                } label: {
                    Label("Add New Worker", systemImage: "plus.circle")
                }
            }
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

    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("Details")
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    if isEditingName {
                        TextField("Project Name", text: $draftName)
                            .font(.title2.weight(.semibold))
                            .tint(.orange)
                        Button {
                            saveNameDescription()
                            isEditingName = false
                        } label: {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.blue)
                        }
                        .buttonStyle(.plain)
                    } else {
                        Text(draftName.isEmpty ? project.name : draftName)
                            .font(.title2.weight(.semibold))
                        Button {
                            draftName = project.name
                            isEditingName = true
                        } label: {
                            Image(systemName: "pencil")
                                .font(.system(size: 16))
                                .foregroundStyle(.orange)
                        }
                        .buttonStyle(.plain)
                    }
                }
                HStack(alignment: .top, spacing: 6) {
                    if isEditingDescription {
                        TextField("Description", text: $draftDescription, axis: .vertical)
                            .lineLimit(2...4)
                            .tint(.orange)
                        Button {
                            saveNameDescription()
                            isEditingDescription = false
                        } label: {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.blue)
                        }
                        .buttonStyle(.plain)
                    } else {
                        Text(draftDescription.isEmpty ? project.description : draftDescription)
                            .font(.body)
                            .foregroundStyle(.primary)
                        Button {
                            draftDescription = project.description
                            isEditingDescription = true
                        } label: {
                            Image(systemName: "pencil")
                                .font(.system(size: 16))
                                .foregroundStyle(.orange)
                        }
                        .buttonStyle(.plain)
                    }
                }
        }
        .alert("Remove log entry?", isPresented: .init(get: { pendingLogToDelete != nil }, set: { if !$0 { pendingLogToDelete = nil } })) {
            Button("Cancel", role: .cancel) {
                pendingLogToDelete = nil
            }
            Button("Remove", role: .destructive) {
                if let id = pendingLogToDelete {
                    model.deleteProgressLogEntry(from: projectId, entryId: id)
                }
                pendingLogToDelete = nil
            }
        } message: {
            Text("This will delete the progress log entry.")
        }
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            EmptyView()
        }
    }

    private var nextStepSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("Next Step")
            HStack {
                if isEditingNextStep {
                    TextField("Next Step", text: $draftNextStep, axis: .vertical)
                        .lineLimit(2...4)
                        .tint(.orange)
                        .focused($isNextStepFocused)
                        .onSubmit { saveNextStep() }
                        .padding(.vertical, 10)
                        .padding(.leading, 12)
                        .padding(.trailing, 12)
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                    Spacer()

                    Button {
                        saveNextStep()
                    } label: {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(.white, .blue)
                    }
                    .buttonStyle(.plain)
                } else {
                Text(project.nextStep)
                    .font(.body)
                    .foregroundStyle(.primary)
                Spacer()
                Button {
                    draftNextStep = project.nextStep
                    withAnimation(.easeInOut) {
                        isEditingNextStep = true
                    }
                    isNextStepFocused = true
                } label: {
                    Image(systemName: "pencil")
                        .font(.system(size: 16))
                        .foregroundStyle(.orange)
                }
            }
        }
        .padding(16)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }

    private var statusSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("Status")
            Toggle(isOn: Binding(
                get: { project.status == "In Progress" },
                set: { isOn in
                    model.updateProjectStatus(projectId, status: isOn ? "In Progress" : "On Hold")
                })
            ) {
                Text(project.status)
            }
            .toggleStyle(SwitchToggleStyle(tint: .orange))
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }

    private var photoGallerySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("Photo Gallery")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    addPhotoButton
                    photoThumbnail
                }
            }
        }
    }

    private var addPhotoButton: some View {
        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(.tertiarySystemGroupedBackground))

                Image(systemName: "plus")
                    .font(.system(size: 40))
                    .foregroundStyle(.orange)
            }
            .frame(width: 140, height: 100)
        }
        .buttonStyle(.borderless)
    }

    private var photoThumbnail: some View {
        ForEach(project.photoURLs, id: \.self) { urlString in
            if let url = URL(string: urlString) {
                KFImage(url)
                    .placeholder { placeholderPhoto }
                    .resizable()
                    .scaledToFill()
                    .frame(width: 140, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .onLongPressGesture {
                        pendingPhotoToDelete = urlString
                    }
            } else {
                placeholderPhoto
            }
        }
        .alert("Remove photo?", isPresented: .init(get: { pendingPhotoToDelete != nil }, set: { if !$0 { pendingPhotoToDelete = nil } })) {
            Button("Cancel", role: .cancel) {
                pendingPhotoToDelete = nil
            }
            Button("Remove", role: .destructive) {
                if let url = pendingPhotoToDelete {
                    model.removePhotoFromProject(projectId, photoURL: url)
                }
                pendingPhotoToDelete = nil
            }
        } message: {
            Text("This will remove the photo from the gallery.")
        }
    }

    private var progressLogSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                sectionHeader("Progress Log")
                Spacer()
                Button {
                    showingProgressLogEntry = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.orange)
                }
            }
            ForEach(project.progressLog) { entry in
                progressLogEntry(entry)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            model.deleteProgressLogEntry(from: projectId, entryId: entry.id)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
    }

    private func progressLogEntry(_ entry: ProgressLogEntry) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(formattedDateTime(entry.date))
                .font(.caption)
                .foregroundStyle(.secondary)

            if editingLogId == entry.id {
                TextField("Progress", text: $draftLogText, axis: .vertical)
                    .lineLimit(2...6)
                    .tint(.orange)
                HStack {
                    Button {
                        model.updateProgressLogEntry(to: projectId, entryId: entry.id, text: draftLogText)
                        editingLogId = nil
                        draftLogText = ""
                    } label: {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.blue)
                    }
                    .buttonStyle(.plain)

                    Button {
                        editingLogId = nil
                        draftLogText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.orange)
                    }
                    .buttonStyle(.plain)
                }
            } else {
                Text(entry.text)
                    .font(.body)
                    .foregroundStyle(.primary)
                HStack(spacing: 12) {
                    Button {
                        editingLogId = entry.id
                        draftLogText = entry.text
                    } label: {
                        Image(systemName: "pencil")
                            .font(.system(size: 16))
                            .foregroundStyle(.orange)
                    }
                    .buttonStyle(.plain)

                    PhotosPicker(selection: $selectedLogPhotoItem, matching: .images) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(.gray)
                    }
                    .buttonStyle(.plain)
                    .onChange(of: selectedLogPhotoItem) { _, newItem in
                        handleLogPhotoSelection(newItem, for: entry.id)
                    }

                    Button {
                        pendingLogToDelete = entry.id
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 16))
                            .foregroundStyle(.red)
                    }
                    .buttonStyle(.plain)
                }
            }

            if !entry.photoURLs.isEmpty {
                entryPhotosView(entry: entry)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.title2)
            .fontWeight(.bold)
            .foregroundStyle(.primary)
    }

    private func formattedDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func workerName(for workerId: UUID) -> String {
        model.workers.first(where: { $0.id == workerId })?.name ?? "Unknown Worker"
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

    private func handlePhotoSelection(_ photoItem: PhotosPickerItem?) {
        guard let photoItem else { return }

        Task {
            if let data = try? await photoItem.loadTransferable(type: Data.self) {
                let filename = "\(UUID().uuidString).jpg"
                let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
                try? data.write(to: tempURL)
                model.addPhotoToProject(projectId, photoURL: tempURL.absoluteString)
            }
            selectedPhotoItem = nil
        }
    }

    private func entryPhotosView(entry: ProgressLogEntry) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(entry.photoURLs, id: \.self) { urlString in
                    if let url = URL(string: urlString) {
                        KFImage(url)
                            .placeholder {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(.tertiarySystemGroupedBackground))
                                    .overlay(
                                        Image(systemName: "photo")
                                            .font(.system(size: 20))
                                            .foregroundStyle(.gray)
                                    )
                            }
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func entryPhotoView(urlString: String) -> some View {
        if let url = URL(string: urlString) {
            KFImage(url)
                .placeholder { placeholderPhoto }
                .resizable()
                .scaledToFill()
                .frame(width: 140, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        } else {
            placeholderPhoto
        }
    }

    private var placeholderPhoto: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(Color(.tertiarySystemGroupedBackground))
            .frame(width: 140, height: 100)
            .overlay(
                Image(systemName: "photo")
                    .font(.system(size: 30))
                    .foregroundStyle(.secondary)
            )
    }

    private func workerRow(assignment: Binding<ProjectWorkerAssignment>) -> some View {
        let workerId = assignment.wrappedValue.workerId
        return NavigationLink {
            WorkerDetailView(workerId: workerId)
                .environment(model)
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(workerName(for: workerId))
                        .font(.headline)
                        .foregroundStyle(.primary)
                    HStack(spacing: 6) {
                        if roleEditing.contains(workerId) {
                            TextField("Role", text: assignment.role)
                                .textFieldStyle(.plain)
                                .tint(.orange)
                                .foregroundStyle(.primary)
                            Button {
                                roleEditing.remove(workerId)
                            } label: {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.blue)
                            }
                            .buttonStyle(.plain)
                        } else {
                    Text(assignment.wrappedValue.role.isEmpty ? "Role not set" : assignment.wrappedValue.role)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                    Button {
                        roleEditing.insert(workerId)
                    } label: {
                        Image(systemName: "pencil")
                            .font(.system(size: 16))
                            .foregroundStyle(.orange)
                    }
                    .buttonStyle(.plain)
                }
                    }
                }
                Spacer()
            }
            .padding(12)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
    }

    private func saveNextStep() {
        let text = draftNextStep.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        model.updateProjectNextStep(projectId, nextStep: text)
        withAnimation(.easeInOut) {
            isEditingNextStep = false
        }
        isNextStepFocused = false
    }

    private func saveNameDescription() {
        let trimmedName = draftName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = draftDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        model.updateProjectDetails(
            projectId,
            name: trimmedName.isEmpty ? project.name : trimmedName,
            description: trimmedDescription.isEmpty ? project.description : trimmedDescription
        )
    }

    private func saveProjectEdits() {
        saveNameDescription()
        isEditingName = false
        isEditingDescription = false
    }

    private func cancelNextStepEdit() {
        draftNextStep = project.nextStep
        withAnimation(.easeInOut) {
            isEditingNextStep = false
        }
        isNextStepFocused = false
    }

    private func handleLogPhotoSelection(_ photoItem: PhotosPickerItem?, for entryId: UUID) {
        guard let photoItem else { return }

        Task {
            if let data = try? await photoItem.loadTransferable(type: Data.self) {
                let filename = "\(UUID().uuidString).jpg"
                let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
                try? data.write(to: tempURL)

                await MainActor.run {
                    model.addPhotoToProgressLogEntry(to: projectId, entryId: entryId, photoURL: tempURL.absoluteString)
                    selectedLogPhotoItem = nil
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        let workers = LuxHomeModel.sampleWorkers
        let projects = LuxHomeModel.sampleProjects(using: workers)
        ProjectDetailView(projectId: projects[0].id)
            .environment(LuxHomeModel.shared)
    }
}
