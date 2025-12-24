//
//  WorkerListView.swift
//  LuxHome
//
//  Created by RJ Kigner on 12/21/25.
//

import SwiftUI

struct WorkerListView: View {
    @Environment(LuxHomeModel.self) private var model

    @State private var selectedTab: WorkerTab = .current

    var filteredWorkers: [LuxWorker] {
        switch selectedTab {
        case .current:
            let activeProjectIds = model.projects
                .filter { $0.status != "Completed" }
                .flatMap { $0.assignedWorkers.map(\.workerId) }
            let activeSet = Set(activeProjectIds)
            return model.workers.filter { activeSet.contains($0.id) }
        case .all:
            return model.workers
        }
    }

    var body: some View {
        ZStack(alignment: .top) {
            backgroundView
            workerListContent
        }
    }

    private var backgroundView: some View {
        Color(.systemGroupedBackground)
            .ignoresSafeArea()
    }

    private var workerListContent: some View {
        VStack(spacing: 0) {
            workersHeader
            filterTabs
            workerList
        }
    }

    private var workersHeader: some View {
        TabHeaderView(title: "Workers") { }
    }

    private var filterTabs: some View {
        Picker("", selection: $selectedTab) {
            ForEach(WorkerTab.allCases) { tab in
                Text(tab.title).tag(tab)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Color(.systemGroupedBackground))
    }

    private var workerList: some View {
        List {
            Section {
                WorkerRowView(workers: filteredWorkers)
            } header: {
                EmptyView()
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
}

enum WorkerTab: String, CaseIterable, Identifiable {
    case current = "Current"
    case all = "All"

    var id: String { rawValue }
    var title: String { rawValue }
}

#Preview {
    WorkerListView()
        .environment(LuxHomeModel.shared)
}
