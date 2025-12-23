//
//  HistoryView.swift
//  LuxHome
//
//  Created by RJ Kigner on 12/23/25.
//

import SwiftUI

struct HistoryView: View {
    @Environment(LuxHomeModel.self) private var model
    @State private var searchText = ""
    @State private var selectedEntry: HistoryEntry?
    @State private var showingPhotoDetail = false

    var filteredHistory: [HistoryEntry] {
        guard !searchText.isEmpty else { return model.history }
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        return model.history.filter { entry in
            let nameMatch = entry.itemName.lowercased().contains(query)
            let dateMatch = dateMatches(query: query, date: entry.timestamp)
            return nameMatch || dateMatch
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                header

                ZStack(alignment: .top) {
                    Color(.systemGroupedBackground)
                        .ignoresSafeArea()

                    if filteredHistory.isEmpty {
                        HistoryEmptyStateView(searchText: searchText)
                    } else {
                        HistoryListView(history: filteredHistory) { entry in
                            selectedEntry = entry
                            showingPhotoDetail = true
                        }
                    }
                }
            }
            .safeAreaBar(edge: .bottom) {
                HistorySearchBar(searchText: $searchText)
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .sheet(isPresented: $showingPhotoDetail) {
                if let entry = selectedEntry {
                    HistoryPhotoDetailView(entry: entry)
                }
            }
        }
    }

    private var header: some View {
        TabHeaderView(title: "History") { }
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

    private func dateMatches(query: String, date: Date) -> Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        let lower = query.lowercased()
        if lower == "today" && calendar.isDate(date, inSameDayAs: today) { return true }
        if lower == "yesterday" && calendar.isDate(date, inSameDayAs: yesterday) { return true }

        let monthFormatter = DateFormatter()
        monthFormatter.locale = Locale.current
        monthFormatter.dateFormat = "LLLL"
        let fullMonth = monthFormatter.string(from: date).lowercased()

        monthFormatter.dateFormat = "LLL"
        let shortMonth = monthFormatter.string(from: date).lowercased()

        let numericFormats = ["M/d/yy", "MM/dd/yy", "M/d/yyyy", "MM/dd/yyyy"]
        let numericStrings: [String] = numericFormats.compactMap { format in
            let fmt = DateFormatter()
            fmt.locale = Locale.current
            fmt.dateFormat = format
            return fmt.string(from: date).lowercased()
        }

        let medium = formattedDate(date).lowercased()

        let candidates = [fullMonth, shortMonth, medium] + numericStrings
        return candidates.contains(where: { $0.contains(query) })
    }
}

#Preview {
    HistoryView()
        .environment(LuxHomeModel.shared)
}
