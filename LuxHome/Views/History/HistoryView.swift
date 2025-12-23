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
        if searchText.isEmpty {
            return model.history
        } else {
            return model.history.filter { entry in
                entry.itemName.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        NavigationStack {
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
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.large)
            .safeAreaBar(edge: .bottom) {
                HistorySearchBar(searchText: $searchText)
            }
            .sheet(isPresented: $showingPhotoDetail) {
                if let entry = selectedEntry {
                    HistoryPhotoDetailView(entry: entry)
                }
            }
        }
    }
}

#Preview {
    HistoryView()
        .environment(LuxHomeModel.shared)
}
