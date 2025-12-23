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
                workerInfoSection
                servicesSection
                scheduleSection
                scheduledVisitsSection
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(worker.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                } label: {
                    Image(systemName: "pencil")
                }
            }
        }
    }

    private var workerInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 16) {
                workerAvatar

                VStack(alignment: .leading, spacing: 4) {
                    Text(worker.name)
                        .font(.title2)
                        .fontWeight(.bold)

                    Text(worker.company)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            contactButtons
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
