//
//  ProjectDetailView.swift
//  LuxHome
//
//  Created by RJ Kigner on 12/21/25.
//

import SwiftUI
import PhotosUI

struct ProjectDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(LuxHomeModel.self) private var model

    let projectId: UUID

    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showingProgressLogEntry = false

    private var project: LuxProject {
        model.projects.first(where: { $0.id == projectId }) ?? LuxProject(
            id: projectId,
            name: "Unknown",
            description: "",
            dueDate: Date()
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                descriptionSection
                nextStepSection
                photoGallerySection
                progressLogSection
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(project.name)
        .navigationBarTitleDisplayMode(.large)
        .onChange(of: selectedPhotoItem) { _, newItem in
            handlePhotoSelection(newItem)
        }
        .sheet(isPresented: $showingProgressLogEntry) {
            ProgressLogEntryView(projectId: projectId)
                .environment(model)
        }
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("Description")
            Text(project.description)
                .font(.body)
                .foregroundStyle(.primary)
        }
    }

    private var nextStepSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("Next Step")
            HStack {
                Text(project.nextStep)
                    .font(.body)
                    .foregroundStyle(.primary)
                Spacer()
                Button {
                } label: {
                    Image(systemName: "pencil")
                        .foregroundStyle(.pink)
                }
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }

    private var photoGallerySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("Photo Gallery")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    addPhotoButton
                    ForEach(project.photoURLs, id: \.self) { photoURL in
                        photoThumbnail
                    }
                }
            }
        }
    }

    private var addPhotoButton: some View {
        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.tertiarySystemGroupedBackground))
                .frame(width: 140, height: 100)
                .overlay(
                    Image(systemName: "plus")
                        .font(.system(size: 40))
                        .foregroundStyle(.pink)
                )
        }
    }

    private var photoThumbnail: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(Color(.tertiarySystemGroupedBackground))
            .frame(width: 140, height: 100)
            .overlay(
                Image(systemName: "photo")
                    .font(.system(size: 30))
                    .foregroundStyle(.secondary)
            )
    }

    private var progressLogSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                sectionHeader("Progress Log")
                Spacer()
                Button {
                    showingProgressLogEntry = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.pink)
                }
            }
            ForEach(project.progressLog) { entry in
                progressLogEntry(entry)
            }
        }
    }

    private func progressLogEntry(_ entry: ProgressLogEntry) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(formattedDateTime(entry.date))
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(entry.text)
                .font(.body)
                .foregroundStyle(.primary)

            if entry.photoURL != nil {
                photoThumbnail
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.title2)
            .fontWeight(.bold)
            .foregroundStyle(.primary)
    }

    private func formattedDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func handlePhotoSelection(_ photoItem: PhotosPickerItem?) {
        guard let photoItem else { return }

        Task {
            if let data = try? await photoItem.loadTransferable(type: Data.self) {
                model.addPhotoToProject(projectId, photoURL: "placeholder://photo")
            }
            selectedPhotoItem = nil
        }
    }
}

#Preview {
    NavigationStack {
        ProjectDetailView(projectId: LuxHomeModel.sampleProjects[0].id)
            .environment(LuxHomeModel.shared)
    }
}
