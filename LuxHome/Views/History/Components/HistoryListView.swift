//
//  HistoryListView.swift
//  LuxHome
//
//  Created by RJ Kigner on 12/23/25.
//

import SwiftUI

struct HistoryListView: View {
    let history: [HistoryEntry]
    let onEntryTap: (HistoryEntry) -> Void

    var groupedHistory: [Date: [HistoryEntry]] {
        Dictionary(grouping: history) { entry in
            Calendar.current.startOfDay(for: entry.timestamp)
        }
    }

    var sortedDates: [Date] {
        groupedHistory.keys.sorted(by: >)
    }

    var body: some View {
        List {
            ForEach(sortedDates, id: \.self) { date in
                Section {
                    ForEach(groupedHistory[date] ?? []) { entry in
                        HistoryEntryRow(entry: entry) {
                            onEntryTap(entry)
                        }
                    }
                } header: {
                    Text(formattedDate(date))
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .textCase(nil)
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    private func formattedDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        if calendar.isDate(date, inSameDayAs: today) {
            return "Today"
        } else if calendar.isDate(date, inSameDayAs: yesterday) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
    }
}

#Preview {
    HistoryListView(
        history: [
            HistoryEntry(
                timestamp: Date(),
                action: .completed,
                itemType: .task,
                itemName: "Install Kitchen Cabinets"
            ),
            HistoryEntry(
                timestamp: Date().addingTimeInterval(-3600),
                action: .photoAdded,
                itemType: .subtask,
                itemName: "Apply primer coat",
                photoURL: "sample://photo1"
            ),
            HistoryEntry(
                timestamp: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
                action: .created,
                itemType: .project,
                itemName: "Garden Remodel"
            ),
            HistoryEntry(
                timestamp: Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
                action: .deleted,
                itemType: .worker,
                itemName: "John Smith"
            )
        ],
        onEntryTap: { _ in }
    )
}
