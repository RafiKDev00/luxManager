//
//  TasksEmptyStateView.swift
//  LuxHome
//
//  Created by RJ Kigner on 12/29/25.
//

import SwiftUI

struct TasksEmptyStateView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "checklist.unchecked")
                .font(.system(size: 60))
                .foregroundStyle(.gray)
            Text("No tasks yet")
                .font(.title3)
                .foregroundStyle(.secondary)
            Text("Tap + to create your first task")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    TasksEmptyStateView()
}
