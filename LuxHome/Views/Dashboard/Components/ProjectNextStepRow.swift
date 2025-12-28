//
//  ProjectNextStepRow.swift
//  LuxHome
//
//  Created by RJ Kigner on 12/28/25.
//

import SwiftUI

struct ProjectNextStepRow: View {
    @Environment(LuxHomeModel.self) private var model
    let project: LuxProject
    let isLast: Bool

    var body: some View {
        NavigationLink(destination: ProjectDetailView(projectId: project.id).environment(model)) {
            HStack(spacing: 12) {
                Image(systemName: "hammer.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(.orange)

                VStack(alignment: .leading, spacing: 4) {
                    Text(project.name)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text(project.nextStep)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)

        if !isLast {
            Divider()
                .padding(.leading, 56)
        }
    }
}
