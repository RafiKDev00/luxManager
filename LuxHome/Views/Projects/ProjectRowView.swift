//
//  ProjectRowView.swift
//  LuxHome
//
//  Created by RJ Kigner on 12/21/25.
//

import SwiftUI

struct ProjectRowView: View {
    let projects: [LuxProject]

    var body: some View {
        ForEach(Array(projects.enumerated()), id: \.element.id) { index, project in
            NavigationLink(destination: ProjectDetailView(projectId: project.id)) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(project.name)
                            .font(.headline)
                        Text(truncatedNextStep(project.nextStep))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                    Spacer()
                    statusBadge(for: project)
                }
            }
            .buttonStyle(.plain)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color(.secondarySystemGroupedBackground))
            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
            .listRowBackground(Color.clear)
            .listRowSeparator(index == projects.count - 1 ? .hidden : .visible, edges: .bottom)
            .clipShape(rowShape(for: index))
        }
    }

    private func statusBadge(for project: LuxProject) -> some View {
        Text(project.status)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(statusColor(for: project.status))
            .clipShape(Capsule())
    }

    private func statusColor(for status: String) -> Color {
        switch status {
        case "In Progress":
            return .blue
        case "Completed":
            return .orange
        case "On Hold":
            return .orange
        default:
            return .gray
        }
    }
    
    private func truncatedNextStep(_ nextStep: String) -> String {
        let words = nextStep.split(separator: " ")
        let firstFiveWords = words.prefix(5).joined(separator: " ")
        return words.count > 5 ? "\(firstFiveWords)..." : firstFiveWords
    }

    private func rowShape(for index: Int) -> UnevenRoundedRectangle {
        UnevenRoundedRectangle(
            topLeadingRadius: index == 0 ? 12 : 0,
            bottomLeadingRadius: index == projects.count - 1 ? 12 : 0,
            bottomTrailingRadius: index == projects.count - 1 ? 12 : 0,
            topTrailingRadius: index == 0 ? 12 : 0,
            style: .continuous
        )
    }
}
