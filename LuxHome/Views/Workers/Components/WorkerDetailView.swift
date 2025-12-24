//
//  WorkerDetailView.swift
//  LuxHome
//
//  Created by RJ Kigner on 12/21/25.
//

import SwiftUI

struct WorkerDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(LuxHomeModel.self) private var model

    let workerId: UUID
    @State private var showingDeleteAlert = false
    @State private var isEditing = false
    @State private var draftName: String = ""
    @State private var draftCompany: String = ""
    @State private var draftPhone: String = ""
    @State private var draftEmail: String = ""
    @State private var draftSpecialization: String = ""
    @State private var draftServicesList: [String] = []
    @State private var newServiceEntry: String = ""
    @State private var draftSchedule: ScheduleType = .oneTime
    @State private var validationError: String?

    private var worker: LuxWorker {
        model.workers.first(where: { $0.id == workerId }) ?? LuxWorker(
            id: workerId,
            name: "Unknown",
            company: "",
            phone: "",
            specialization: ""
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                if isEditing {
                    WorkerEditForm(
                        name: $draftName,
                        company: $draftCompany,
                        phone: $draftPhone,
                        email: $draftEmail,
                        specialization: $draftSpecialization,
                        serviceTags: $draftServicesList,
                        newServiceEntry: $newServiceEntry,
                        schedule: $draftSchedule
                    ) {
                        showingDeleteAlert = true
                    }
                } else {
                    workerInfoSection
                    servicesSection
                    scheduleSection
                }
                scheduledVisitsSection
                projectsSection
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(worker.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(isEditing ? "Done" : "Edit") {
                    if isEditing {
                        saveEdits()
                    } else {
                        loadDrafts()
                    }
                    withAnimation(.easeInOut) {
                        isEditing.toggle()
                    }
                }
            }
        }
        .alert("Delete Worker", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                model.deleteWorker(workerId)
                dismiss()
            }
        } message: {
            Text("Are you sure you want to remove this worker? This will also unassign them from any projects.")
        }
        .alert("Invalid Entry", isPresented: .constant(validationError != nil), actions: {
            Button("OK", role: .cancel) {
                validationError = nil
            }
        }, message: {
            if let validationError {
                Text(validationError)
            }
        })
        .onAppear(perform: loadDrafts)
    }

    private var workerInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 16) {
                workerAvatar

                VStack(alignment: .leading, spacing: 4) {
                    if isEditing {
                        TextField("Name", text: $draftName)
                            .font(.title2)
                            .fontWeight(.bold)

                        TextField("Company", text: $draftCompany)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else {
                        Text(worker.name)
                            .font(.title2)
                            .fontWeight(.bold)

                        Text(worker.company)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            if isEditing {
                VStack(alignment: .leading, spacing: 12) {
                    TextField("Phone", text: $draftPhone)
                        .keyboardType(.phonePad)
                        .padding(10)
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    TextField("Email", text: $draftEmail)
                        .keyboardType(.emailAddress)
                        .padding(10)
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    TextField("Specialization", text: $draftSpecialization)
                        .textInputAutocapitalization(.words)
                        .padding(10)
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
            } else {
                contactButtons
            }
        }
    }

    private var workerAvatar: some View {
        Circle()
            .fill(Color(.secondarySystemGroupedBackground))
            .frame(width: 70, height: 70)
            .overlay(
                Text(worker.name.prefix(1))
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
            )
    }

    private var contactButtons: some View {
        HStack(spacing: 12) {
            contactButton(icon: "phone.fill", text: "Call", action: {})
            if worker.email != nil {
                contactButton(icon: "envelope.fill", text: "Email", action: {})
            }
        }
    }

    private func contactButton(icon: String, text: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(text)
            }
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.blue)
            .clipShape(Capsule())
        }
    }

    private var servicesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Services Provided")

            FlowLayout(spacing: 8) {
                ForEach(worker.serviceTypes, id: \.self) { service in
                    serviceChip(service)
                }
            }
        }
    }

    private func serviceChip(_ service: String) -> some View {
        Text(service)
            .font(.subheadline)
            .foregroundStyle(.primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            .lineLimit(1)
    }

    private var scheduleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Schedule Type")

            if isEditing {
                Picker("Schedule", selection: $draftSchedule) {
                    ForEach(ScheduleType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.menu)
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            } else {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundStyle(.blue)
                    Text(worker.scheduleType.rawValue)
                        .font(.body)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }

    private var scheduledVisitsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                sectionHeader("Scheduled Visits")
                Spacer()
                Button {
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.blue)
                }
            }

            ForEach(worker.scheduledVisits) { visit in
                scheduledVisitCard(visit)
            }
        }
    }

    private var projectsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Projects")
            let (current, past) = projectsForWorker()

            if current.isEmpty && past.isEmpty {
                Text("No projects")
                    .foregroundStyle(.secondary)
            }

            if !current.isEmpty {
                Text("Current")
                    .font(.subheadline.bold())
                ForEach(current) { project in
                    projectRow(project)
                }
            }

            if !past.isEmpty {
                Text("Past")
                    .font(.subheadline.bold())
                ForEach(past) { project in
                    projectRow(project)
                }
            }
        }
    }

    private func projectRow(_ project: LuxProject) -> some View {
        HStack {
            Text(project.name)
                .font(.body)
            Spacer()
            Text(project.status)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private func scheduledVisitCard(_ visit: ScheduledVisit) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundStyle(.blue)
                Text(formattedDateTime(visit.date))
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Spacer()

                if visit.isDone {
                    Text("Done")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange)
                        .clipShape(Capsule())
                } else {
                    Toggle("", isOn: .constant(false))
                        .labelsHidden()
                }
            }

            if !visit.notes.isEmpty {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "note.text")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(visit.notes)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if !visit.checklist.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Checklist:")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)

                    ForEach(visit.checklist) { item in
                        checklistRow(item)
                    }
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func checklistRow(_ item: ChecklistItem) -> some View {
        HStack(spacing: 8) {
            Image(systemName: item.isCompleted ? "checkmark.square.fill" : "square")
                .foregroundStyle(item.isCompleted ? .blue : .secondary)
            Text(item.title)
                .font(.caption)
                .foregroundStyle(item.isCompleted ? .secondary : .primary)
                .strikethrough(item.isCompleted)
        }
    }

    private func projectsForWorker() -> ([LuxProject], [LuxProject]) {
        let assigned = model.projects.filter { project in
            project.assignedWorkers.contains(where: { $0.workerId == workerId })
        }
        let current = assigned.filter { $0.status != "Completed" }
        let past = assigned.filter { $0.status == "Completed" }
        return (current, past)
    }

    private func saveEdits() {
        if !draftPhone.isEmpty && !isValidPhone(draftPhone) {
            validationError = "Please enter a valid phone number."
            return
        }
        if !draftEmail.isEmpty && !isValidEmail(draftEmail) {
            validationError = "Please enter a valid email address."
            return
        }

        model.updateWorker(
            workerId,
            name: draftName.isEmpty ? worker.name : draftName,
            company: draftCompany.isEmpty ? worker.company : draftCompany,
            phone: draftPhone.isEmpty ? worker.phone : draftPhone,
            email: draftEmail.isEmpty ? worker.email : draftEmail,
            specialization: draftSpecialization.isEmpty ? worker.specialization : draftSpecialization,
            serviceTypes: draftServicesList
        )
        loadDrafts()
    }

    private func loadDrafts() {
        draftName = worker.name
        draftCompany = worker.company
        draftPhone = worker.phone
        draftEmail = worker.email ?? ""
        draftSpecialization = worker.specialization
        draftServicesList = worker.serviceTypes
        newServiceEntry = ""
        draftSchedule = worker.scheduleType
    }

    private var deleteButton: some View {
        Button(role: .destructive) {
            showingDeleteAlert = true
        } label: {
            Text("Delete Contact")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red.opacity(0.15))
                .foregroundStyle(.red)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
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

    private func isValidEmail(_ email: String) -> Bool {
        let pattern = #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#
        return NSPredicate(format: "SELF MATCHES[c] %@", pattern).evaluate(with: email)
    }

    private func isValidPhone(_ phone: String) -> Bool {
        let trimmed = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        let pattern = #"^[+0-9()\-\s]{7,}$"#
        return NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: trimmed)
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }

                positions.append(CGPoint(x: currentX, y: currentY))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
            }

            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

#Preview {
    NavigationStack {
        WorkerDetailView(workerId: LuxHomeModel.sampleWorkers[0].id)
            .environment(LuxHomeModel.shared)
    }
}
