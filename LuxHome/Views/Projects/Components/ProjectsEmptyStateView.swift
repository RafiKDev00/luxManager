//
//  ProjectsEmptyStateView.swift
//  LuxHome
//
//  Created by RJ Kigner on 12/29/25.
//

import SwiftUI

struct ProjectsEmptyStateView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "wrench.and.screwdriver")
                .font(.system(size: 60))
                .foregroundStyle(.gray)
            Text("No projects yet")
                .font(.title3)
                .foregroundStyle(.secondary)
            Text("Tap + to create your first project")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ProjectsEmptyStateView()
}
