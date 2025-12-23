//
//  ProjectListView.swift
//  LuxHome
//
//  Created by RJ Kigner on 12/21/25.
//

import SwiftUI

struct ProjectListView: View {
    @Environment(LuxHomeModel.self) private var model

    var body: some View {
        ZStack(alignment: .top) {
            backgroundView

            projectList
        }
    }

    private var backgroundView: some View {
        Color(.systemGroupedBackground)
            .ignoresSafeArea()
    }

    private var projectList: some View {
        VStack(spacing: 16) {
            projectsHeader

            List {
                Section {
                    ProjectRowView(projects: model.projects)
                } header: {
                    EmptyView()
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
    }

    private var projectsHeader: some View {
        TabHeaderView(title: "Projects") { }
    }
}

#Preview {
    ProjectListView()
        .environment(LuxHomeModel.shared)
}
