//
//  WorkerListView.swift
//  LuxHome
//
//  Created by RJ Kigner on 12/21/25.
//

import SwiftUI

struct WorkerListView: View {
    @Environment(LuxHomeModel.self) private var model

    @State private var selectedFilter: WorkerFilter = .all

    var filteredWorkers: [LuxWorker] {
        switch selectedFilter {
        case .all:
            return model.workers
        case .cleaner:
            return model.workers.filter { $0.specialization == "Cleaner" }
        case .gardener:
            return model.workers.filter { $0.specialization == "Gardener" }
        case .poolService:
            return model.workers.filter { $0.specialization == "Pool Service" }
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
        HStack {
            EngravedFont(text: "Workers", font: .system(size: 40, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)

        }
        .padding(.horizontal)
        .padding(.top, 8)
        .background(Color(.systemGroupedBackground))
    }

    private var filterTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(WorkerFilter.allCases) { filter in
                    filterButton(filter)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .background(Color(.systemGroupedBackground))
    }

    private func filterButton(_ filter: WorkerFilter) -> some View {
        Button {
            selectedFilter = filter
        } label: {
            Text(filter.rawValue)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(selectedFilter == filter ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(selectedFilter == filter ? Color.blue : Color(.secondarySystemGroupedBackground))
                .clipShape(Capsule())
        }
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

enum WorkerFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case cleaner = "Cleaner"
    case gardener = "Gardener"
    case poolService = "Pool Service"

    var id: String { rawValue }
}

#Preview {
    WorkerListView()
        .environment(LuxHomeModel.shared)
}
