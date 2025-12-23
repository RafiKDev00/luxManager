//
//  HistoryPhotoDetailView.swift
//  LuxHome
//
//  Created by RJ Kigner on 12/23/25.
//

import SwiftUI

struct HistoryPhotoDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let entry: HistoryEntry

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    photoPlaceholder

                    entryDetails

                    Spacer()
                }
                .padding(.top)
            }
            .navigationTitle("Photo Detail")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var photoPlaceholder: some View {
        ZStack {
            gradientBackground
            samplePhotoContent
        }
        .padding()
    }

    private var gradientBackground: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [Color.orange.opacity(0.3), Color.orange.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(maxWidth: .infinity)
            .frame(height: 400)
    }

    private var samplePhotoContent: some View {
        VStack(spacing: 16) {
            Image(systemName: sampleImageName)
                .font(.system(size: 120))
                .foregroundStyle(.orange.opacity(0.8))

            Text("Sample Photo")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text(entry.photoURL ?? "")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }

    private var sampleImageName: String {
        switch entry.itemType {
        case .task, .subtask:
            return ["hammer.fill", "wrench.and.screwdriver.fill", "paintbrush.fill", "scissors"].randomElement() ?? "hammer.fill"
        case .project:
            return ["house.fill", "building.2.fill", "ladybug.fill"].randomElement() ?? "house.fill"
        case .worker:
            return ["person.fill.checkmark", "person.2.fill"].randomElement() ?? "person.fill.checkmark"
        }
    }

    private var entryDetails: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(entry.displayText)
                    .font(.title3)
                    .fontWeight(.semibold)
                Spacer()
            }

            HStack {
                Image(systemName: "clock")
                    .foregroundStyle(.secondary)
                Text(formattedDateTime(entry.timestamp))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .padding(.horizontal)
    }

    private func formattedDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview("Task Photo") {
    HistoryPhotoDetailView(
        entry: HistoryEntry(
            timestamp: Date(),
            action: .photoAdded,
            itemType: .subtask,
            itemName: "Apply primer coat",
            photoURL: "sample://photo1"
        )
    )
}

#Preview("Project Photo") {
    HistoryPhotoDetailView(
        entry: HistoryEntry(
            timestamp: Date(),
            action: .photoAdded,
            itemType: .project,
            itemName: "Garden Remodel",
            photoURL: "sample://irrigation_photo"
        )
    )
}
