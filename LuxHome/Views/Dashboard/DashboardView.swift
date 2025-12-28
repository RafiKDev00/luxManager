//
//  DashboardView.swift
//  LuxHome
//
//  Created by RJ Kigner on 12/28/25.
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
                        headerSection

                        if !model.tasksThisWeek.isEmpty {
                            maintenanceTasksSection
                        }

                        if !model.workersThisWeek.isEmpty {
                            workersSection
                        }

                        if !model.projectNextSteps.isEmpty {
                            projectNextStepsSection
                        }

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

    private var headerSection: some View {
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
                ForEach(Array(model.workersThisWeek.enumerated()), id: \.offset) { index, item in
                    WorkerVisitRow(worker: item.worker, visit: item.visit, isLast: index == model.workersThisWeek.count - 1)
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

#Preview {
    DashboardView()
        .environment(LuxHomeModel.shared)
}
