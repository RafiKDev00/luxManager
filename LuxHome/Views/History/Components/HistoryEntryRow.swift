//
//  HistoryEntryRow.swift
//  LuxHome
//
//  Created by RJ Kigner on 12/23/25.
//

import SwiftUI

struct HistoryEntryRow: View {
    let entry: HistoryEntry
    let onTap: () -> Void

    var body: some View {
        Button {
            if entry.photoURL != nil {
                onTap()
            }
        } label: {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.displayText)
                        .font(.body)
                        .foregroundStyle(.primary)

                    Text(formattedTime(entry.timestamp))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if let photoURL = entry.photoURL {
                    Image(systemName: "photo")
                        .font(.system(size: 20))
                        .foregroundStyle(.orange)
                }

                HistoryActionIcon(action: entry.action)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(Color(.secondarySystemGroupedBackground))
        }
        .buttonStyle(.plain)
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }

    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview("Task Completed") {
    HistoryEntryRow(
        entry: HistoryEntry(
            timestamp: Date(),
            action: .completed,
            itemType: .task,
            itemName: "Install New Kitchen Cabinets"
        ),
        onTap: {}
    )
}

#Preview("Photo Added") {
    HistoryEntryRow(
        entry: HistoryEntry(
            timestamp: Date(),
            action: .photoAdded,
            itemType: .subtask,
            itemName: "Apply primer coat",
            photoURL: "sample://photo1"
        ),
        onTap: {}
    )
}

#Preview("Project Created") {
    HistoryEntryRow(
        entry: HistoryEntry(
            timestamp: Date().addingTimeInterval(-3600),
            action: .created,
            itemType: .project,
            itemName: "Garden Remodel"
        ),
        onTap: {}
    )
}

#Preview("Worker Deleted") {
    HistoryEntryRow(
        entry: HistoryEntry(
            timestamp: Date().addingTimeInterval(-7200),
            action: .deleted,
            itemType: .worker,
            itemName: "John Smith"
        ),
        onTap: {}
    )
}
