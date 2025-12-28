//
//  DashboardView.swift
//  LuxHome
//
//  Created by RJ  Kigner on 12/28/25.
//

import SwiftUI

struct DashboardView: View {
    @Environment(LuxHomeModel.self) private var model

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        VStack(alignment: .leading, spacing: 4) {
                            Text("This Week")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            Text(weekDateRange)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)

                        // Maintenance Tasks Section
                        if !model.tasksThisWeek.isEmpty {
                            maintenanceTasksSection
                        }

                        // Workers Section
                        if !model.workersThisWeek.isEmpty {
                            workersSection
                        }

                        // Project Next Steps Section
                        if !model.projectNextSteps.isEmpty {
                            projectNextStepsSection
                        }

                        // Empty state
                        if model.tasksThisWeek.isEmpty && model.workersThisWeek.isEmpty && model.projectNextSteps.isEmpty {
                            emptyState
                        }
                    }
                    .padding(.bottom, 32)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var maintenanceTasksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "Maintenance Tasks", icon: "checklist.unchecked")

            VStack(spacing: 0) {
                ForEach(Array(model.tasksThisWeek.enumerated()), id: \.element.id) { index, task in
                    MaintenanceTaskRow(task: task, isLast: index == model.tasksThisWeek.count - 1)
                }
            }
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.horizontal, 16)
    }

    private var workersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "Scheduled Workers", icon: "person.2")

            VStack(spacing: 0) {
                ForEach(Array(model.workersThisWeek.enumerated()), id: \.element.worker.id) { index, item in
                    WorkerVisitRow(worker: item.worker, nextVisit: item.nextVisit, isLast: index == model.workersThisWeek.count - 1)
                }
            }
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.horizontal, 16)
    }

    private var projectNextStepsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "Project Next Steps", icon: "wrench.and.screwdriver")

            VStack(spacing: 0) {
                ForEach(Array(model.projectNextSteps.enumerated()), id: \.element.id) { index, project in
                    ProjectNextStepRow(project: project, isLast: index == model.projectNextSteps.count - 1)
                }
            }
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.horizontal, 16)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.checkmark")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            Text("All Clear This Week!")
                .font(.title2)
                .fontWeight(.semibold)
            Text("No maintenance tasks, worker visits, or project next steps scheduled.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .padding(.top, 100)
    }

    private func sectionHeader(title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.orange)
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
        }
    }

    private var weekDateRange: String {
        let calendar = Calendar.current
        let now = Date()
        let endOfWeek = calendar.date(byAdding: .day, value: 7, to: now) ?? now

        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"

        let startString = formatter.string(from: now)
        let endString = formatter.string(from: endOfWeek)

        return "\(startString) - \(endString)"
    }
}

// MARK: - Row Components
struct MaintenanceTaskRow: View {
    let task: LuxTask
    let isLast: Bool

    var body: some View {
        NavigationLink(destination: TaskDetailView(task: task).environment(LuxHomeModel.shared)) {
            HStack(spacing: 12) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundStyle(.orange)

                VStack(alignment: .leading, spacing: 4) {
                    Text(task.name)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    if let dueDate = task.nextDueDate {
                        Text(formattedDate(dueDate))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                Text(task.isCompleted ? "Completed" : task.dueDateDescription())
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)

        if !isLast {
            Divider()
                .padding(.leading, 48)
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: date)
    }
}

struct WorkerVisitRow: View {
    @Environment(LuxHomeModel.self) private var model
    let worker: LuxWorker
    let nextVisit: Date
    let isLast: Bool

    var body: some View {
        NavigationLink(destination: WorkerDetailView(workerId: worker.id).environment(model)) {
            HStack(spacing: 12) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(.orange)

                VStack(alignment: .leading, spacing: 4) {
                    Text(worker.name)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text(worker.specialization)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(formattedDate(nextVisit))
                        .font(.subheadline)
                        .foregroundStyle(.primary)

                    Text(relativeDateDescription(nextVisit))
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)

        if !isLast {
            Divider()
                .padding(.leading, 56)
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        return formatter.string(from: date)
    }

    private func relativeDateDescription(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = calendar.startOfDay(for: Date())
        let target = calendar.startOfDay(for: date)

        let days = calendar.dateComponents([.day], from: now, to: target).day ?? 0

        if days == 0 {
            return "Today"
        } else if days == 1 {
            return "Tomorrow"
        } else {
            return "In \(days) days"
        }
    }
}

struct ProjectNextStepRow: View {
    @Environment(LuxHomeModel.self) private var model
    let project: LuxProject
    let isLast: Bool

    var body: some View {
        NavigationLink(destination: ProjectDetailView(projectId: project.id).environment(model)) {
            HStack(spacing: 12) {
                Image(systemName: "hammer.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(.orange)

                VStack(alignment: .leading, spacing: 4) {
                    Text(project.name)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text(project.nextStep)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)

        if !isLast {
            Divider()
                .padding(.leading, 56)
        }
    }
}

#Preview {
    DashboardView()
        .environment(LuxHomeModel.shared)
}
