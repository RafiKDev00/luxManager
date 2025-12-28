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
    @State private var selectedPhotoItems: [PhotosPickerItem] = []

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
            PhotosPicker(selection: $selectedPhotoItems, maxSelectionCount: 10, matching: .images) {
                HStack {
                    Image(systemName: selectedPhotoItems.isEmpty ? "photo" : "photo.fill")
                        .foregroundStyle(selectedPhotoItems.isEmpty ? .secondary : Color.orange)
                    Text(selectedPhotoItems.isEmpty ? "Add Photos (Optional)" : "\(selectedPhotoItems.count) Photo\(selectedPhotoItems.count == 1 ? "" : "s") Selected")
                        .foregroundStyle(selectedPhotoItems.isEmpty ? .primary : Color.orange)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        } header: {
            Text("Attach Photos")
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
            var photoURLs: [String] = []

            for photoItem in selectedPhotoItems {
                if let data = try? await photoItem.loadTransferable(type: Data.self) {
                    let filename = "\(UUID().uuidString).jpg"
                    let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
                    try? data.write(to: tempURL)
                    photoURLs.append(tempURL.absoluteString)
                }
            }

            model.addProgressLogEntry(
                to: projectId,
                text: entryText,
                photoURLs: photoURLs
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
