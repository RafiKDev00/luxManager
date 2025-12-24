//
//  ProgressLogEntryView.swift
//  LuxHome
//
//  Created by RJ Kigner on 12/21/25.
//

import SwiftUI
import PhotosUI

struct ProgressLogEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(LuxHomeModel.self) private var model

    let projectId: UUID

    @State private var entryText: String = ""
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var hasPhoto: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                entrySection
                photoSection
            }
            .safeAreaBar(edge: .top, spacing: 0) {
                topBar
            }
        }
    }

    private var entrySection: some View {
        Section {
            TextField("Progress update", text: $entryText, axis: .vertical)
                .lineLimit(3...10)
        } header: {
            Text("Progress Update")
        }
    }

    private var photoSection: some View {
        Section {
            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                HStack {
                    Image(systemName: hasPhoto ? "photo.fill" : "photo")
                        .foregroundStyle(hasPhoto ? .orange : .secondary)
                    Text(hasPhoto ? "Photo Added" : "Add Photo (Optional)")
                        .foregroundStyle(hasPhoto ? .orange : .primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        } header: {
            Text("Attach Photo")
        }
        .onChange(of: selectedPhotoItem) { _, newItem in
            hasPhoto = newItem != nil
        }
    }

    private var topBar: some View {
        HStack {
            closeButton
            Spacer()
            titleText
            Spacer()
            saveButton
        }
        .padding(.top, 8)
        .padding(.bottom, 8)
        .background(Color.clear)
    }

    private var closeButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark")
        }
        .buttonStyle(IconButtonStyle(type: .close))
        .padding(.leading, 16)
    }

    private var titleText: some View {
        Text("New Entry")
            .font(.system(size: 24, weight: .bold))
    }

    private var saveButton: some View {
        Button {
            saveEntry()
        } label: {
            Image(systemName: "checkmark")
        }
        .buttonStyle(IconButtonStyle(type: .check))
        .disabled(entryText.isEmpty)
        .opacity(entryText.isEmpty ? 0.8 : 1.0)
        .padding(.trailing, 16)
    }

    private func saveEntry() {
        Task {
            var photoURL: String? = nil
            if let photoItem = selectedPhotoItem,
               let data = try? await photoItem.loadTransferable(type: Data.self) {
                let filename = "\(UUID().uuidString).jpg"
                let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
                try? data.write(to: tempURL)
                photoURL = tempURL.absoluteString
            }

            model.addProgressLogEntry(
                to: projectId,
                text: entryText,
                photoURL: photoURL
            )
            dismiss()
        }
    }
}

#Preview {
    @Previewable @State var showingSheet = true

    Color.clear
        .sheet(isPresented: $showingSheet) {
            ProgressLogEntryView(projectId: UUID())
                .environment(LuxHomeModel.shared)
        }
}
