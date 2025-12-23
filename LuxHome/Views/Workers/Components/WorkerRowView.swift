//
//  WorkerRowView.swift
//  LuxHome
//
//  Created by RJ Kigner on 12/21/25.
//

import SwiftUI

struct WorkerRowView: View {
    @Environment(LuxHomeModel.self) private var model

    let workers: [LuxWorker]

    var body: some View {
        ForEach(Array(workers.enumerated()), id: \.element.id) { index, worker in
            NavigationLink(destination: WorkerDetailView(workerId: worker.id)) {
                workerRow(for: worker)
            }
            .buttonStyle(.plain)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color(.secondarySystemGroupedBackground))
            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
            .listRowBackground(Color.clear)
            .listRowSeparator(index == workers.count - 1 ? .hidden : .visible, edges: .bottom)
            .clipShape(rowShape(for: index))
        }
    }

    private func workerRow(for worker: LuxWorker) -> some View {
        HStack(spacing: 12) {
            workerAvatar(for: worker)

            VStack(alignment: .leading, spacing: 4) {
                Text(worker.name)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(worker.company)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if let nextVisit = worker.nextVisit {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.caption2)
                        Text("Next Visit: \(formattedDate(nextVisit))")
                            .font(.caption2)
                    }
                    .foregroundStyle(.secondary)
                }

                HStack(spacing: 6) {
                    ForEach(worker.serviceTypes.prefix(3), id: \.self) { service in
                        serviceTag(service)
                    }
                }
                .padding(.top, 4)
            }

            Spacer()
        }
    }

    private func workerAvatar(for worker: LuxWorker) -> some View {
        Circle()
            .fill(Color(.tertiarySystemGroupedBackground))
            .frame(width: 50, height: 50)
            .overlay(
                Text(worker.name.prefix(1))
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
            )
    }

    private func serviceTag(_ service: String) -> some View {
        Text(service)
            .font(.caption2)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Color(.tertiarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy - h:mm a"
        return formatter.string(from: date)
    }

    private func rowShape(for index: Int) -> UnevenRoundedRectangle {
        UnevenRoundedRectangle(
            topLeadingRadius: index == 0 ? 12 : 0,
            bottomLeadingRadius: index == workers.count - 1 ? 12 : 0,
            bottomTrailingRadius: index == workers.count - 1 ? 12 : 0,
            topTrailingRadius: index == 0 ? 12 : 0,
            style: .continuous
        )
    }
}
