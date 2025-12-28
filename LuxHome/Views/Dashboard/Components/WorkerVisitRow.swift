//
//  WorkerVisitRow.swift
//  LuxHome
//
//  Created by RJ Kigner on 12/28/25.
//

import SwiftUI

struct WorkerVisitRow: View {
    @Environment(LuxHomeModel.self) private var model
    let worker: LuxWorker
    let visit: ScheduledVisit
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

                    if let projectId = visit.projectId,
                       let project = model.projects.first(where: { $0.id == projectId }) {
                        HStack(spacing: 4) {
                            Image(systemName: "hammer.fill")
                                .font(.caption2)
                            Text(project.name)
                        }
                        .font(.subheadline)
                        .foregroundStyle(.orange)
                    } else {
                        Text(worker.specialization)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(formattedDate(visit.date))
                        .font(.subheadline)
                        .foregroundStyle(.primary)

                    Text(relativeDateDescription(visit.date))
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
