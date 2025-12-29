//
//  PhotoOverlayView.swift
//  LuxHome
//
//  Created by RJ Kigner on 12/29/25.
//

import SwiftUI
import Kingfisher
import PhotosUI

struct PhotoOverlayView: View {
    let photoURLs: [String]
    @Binding var selectedIndex: Int
    @Binding var isPresented: Bool
    var onDelete: ((String) -> Void)? = nil
    var onAddPhoto: ((String) -> Void)? = nil

    @State private var showingDeleteAlert = false
    @State private var selectedPhotoItem: PhotosPickerItem?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                TabView(selection: $selectedIndex) {
                    ForEach(Array(photoURLs.enumerated()), id: \.offset) { index, urlString in
                        if let url = URL(string: urlString) {
                            KFImage(url)
                                .placeholder {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.systemGray5))
                                        .overlay(
                                            Image(systemName: "photo")
                                                .font(.system(size: 60))
                                                .foregroundStyle(.gray)
                                        )
                                }
                                .resizable()
                                .scaledToFit()
                                .padding()
                                .tag(index)
                        } else {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray5))
                                .overlay(
                                    Image(systemName: "photo")
                                        .font(.system(size: 60))
                                        .foregroundStyle(.gray)
                                )
                                .padding()
                                .tag(index)
                        }
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if onDelete != nil {
                        Button {
                            showingDeleteAlert = true
                        } label: {
                            Image(systemName: "trash.circle.fill")
                                .font(.system(size: 28))
                                .foregroundStyle(.white, .red.opacity(0.8))
                        }
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(.white, .gray.opacity(0.6))
                    }
                }

                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        Text("\(selectedIndex + 1) of \(photoURLs.count)")
                            .font(.subheadline)
                            .foregroundStyle(.white)

                        Spacer()

                        if onAddPhoto != nil {
                            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 24))
                                    .foregroundStyle(.white)
                                    .padding(8)
                            }
                        }
                    }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarBackground(.hidden, for: .bottomBar)
            .alert("Delete Photo", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteCurrentPhoto()
                }
            } message: {
                Text("Are you sure you want to delete this photo?")
            }
            .onChange(of: selectedPhotoItem) { _, newItem in
                handlePhotoSelection(newItem)
            }
        }
    }

    private func deleteCurrentPhoto() {
        guard selectedIndex < photoURLs.count else { return }
        let photoURL = photoURLs[selectedIndex]

        onDelete?(photoURL)

        if photoURLs.count == 1 {
            isPresented = false
        } else if selectedIndex >= photoURLs.count - 1 {
            selectedIndex = max(0, photoURLs.count - 2)
        }
    }

    private func handlePhotoSelection(_ photoItem: PhotosPickerItem?) {
        guard let photoItem else { return }

        Task {
            if let data = try? await photoItem.loadTransferable(type: Data.self) {
                let filename = "\(UUID().uuidString).jpg"
                let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
                try? data.write(to: tempURL)

                onAddPhoto?(tempURL.absoluteString)
            }
            selectedPhotoItem = nil
        }
    }
}

#Preview {
    @Previewable @State var selectedIndex = 0
    @Previewable @State var isPresented = true

    PhotoOverlayView(
        photoURLs: [
            "https://images.unsplash.com/photo-1483728642387-6c3bdd6c93e5",
            "https://images.unsplash.com/photo-1444464666168-49d633b86797",
            "https://images.unsplash.com/photo-1508817628294-5a453fa0b8fb"
        ],
        selectedIndex: $selectedIndex,
        isPresented: $isPresented,
        onDelete: { photoURL in
            print("Delete photo: \(photoURL)")
        },
        onAddPhoto: { photoURL in
            print("Add photo: \(photoURL)")
        }
    )
}
