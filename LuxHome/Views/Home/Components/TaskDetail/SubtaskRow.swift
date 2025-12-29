//
//  SubtaskRow.swift
//  LuxHome
//
//  Created by RJ Kigner on 12/24/25.
//

import SwiftUI
import Kingfisher
import PhotosUI

struct SubtaskRow: View {
    @Environment(LuxHomeModel.self) private var model

    let subtask: LuxSubTask
    let index: Int
    let totalCount: Int
    let isEditMode: Bool
    let isLast: Bool
    let onPhotoTap: (UUID) -> Void
    let onDelete: (UUID) -> Void

    @State private var showingPhotoOverlay = false
    @State private var selectedPhotoIndex: Int = 0

    var body: some View {
        HStack {
            subtaskInfo
            Spacer()

            if isEditMode {
                swipeIndicator
            }

            if !subtask.photoURLs.isEmpty && !isEditMode {
                photoThumbnailStrip
            }

            subtaskActions
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color(.secondarySystemGroupedBackground))
        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
        .listRowBackground(Color.clear)
        .listRowSeparator(isLast ? .hidden : .visible, edges: .bottom)
        .clipShape(rowShape)
        .sheet(isPresented: $showingPhotoOverlay) {
            PhotoOverlayView(
                photoURLs: subtask.photoURLs,
                selectedIndex: $selectedPhotoIndex,
                isPresented: $showingPhotoOverlay,
                onDelete: { photoURL in
                    model.deletePhotoFromSubtask(subtask.id, photoURL: photoURL)
                },
                onAddPhoto: { photoURL in
                    model.addPhotoToSubtask(subtask.id, photoURL: photoURL)
                }
            )
        }
    }

    private var subtaskInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(subtask.name)
                .font(.headline)

            Text(subtask.isCompleted ? "Completed" : "Incomplete")
                .font(.caption)
                .foregroundStyle(subtask.isCompleted ? .orange : .gray)
        }
    }

    private var swipeIndicator: some View {
        HStack(spacing: 4) {
            Image(systemName: "chevron.left")
                .font(.caption)
                .foregroundStyle(.gray.opacity(0.5))
            Text("Swipe")
                .font(.caption2)
                .foregroundStyle(.gray.opacity(0.6))
        }
        .padding(.trailing, 8)
    }

    @ViewBuilder
    private var subtaskActions: some View {
        if isEditMode {
            deleteButton
        } else {
            cameraButton

            if subtask.isCompleted {
                checkmarkButton
            } else {
                manualCompletionButton
            }
        }
    }

    private var deleteButton: some View {
        Button {
            onDelete(subtask.id)
        } label: {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 24))
                .foregroundStyle(.red)
        }
        .buttonStyle(.plain)
    }

    private var cameraButton: some View {
        Button {
            onPhotoTap(subtask.id)
        } label: {
            Image(systemName: "camera.fill")
                .font(.system(size: 24))
                .foregroundStyle(.gray)
        }
        .buttonStyle(.plain)
    }

    private var checkmarkButton: some View {
        Button {
            if !subtask.photoURLs.isEmpty {
                selectedPhotoIndex = 0
                showingPhotoOverlay = true
            } else {
                model.toggleSubtaskCompletion(subtask.id)
            }
        } label: {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 24))
                .foregroundStyle(.orange)
        }
        .buttonStyle(.plain)
    }

    private var photoThumbnailStrip: some View {
        HStack(spacing: 4) {
            ForEach(Array(subtask.photoURLs.prefix(2).enumerated()), id: \.offset) { index, urlString in
                if let url = URL(string: urlString) {
                    KFImage(url)
                        .placeholder {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color(.tertiarySystemGroupedBackground))
                                .overlay(
                                    Image(systemName: "photo")
                                        .font(.system(size: 16))
                                        .foregroundStyle(.gray)
                                )
                        }
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .onTapGesture {
                            selectedPhotoIndex = index
                            showingPhotoOverlay = true
                        }
                } else {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(.tertiarySystemGroupedBackground))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 16))
                                .foregroundStyle(.gray)
                        )
                        .onTapGesture {
                            selectedPhotoIndex = index
                            showingPhotoOverlay = true
                        }
                }
            }

            if subtask.photoURLs.count > 2 {
                ZStack {
                    if let url = URL(string: subtask.photoURLs[2]) {
                        KFImage(url)
                            .placeholder {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color(.tertiarySystemGroupedBackground))
                                    .overlay(
                                        Image(systemName: "photo")
                                            .font(.system(size: 16))
                                            .foregroundStyle(.gray)
                                    )
                            }
                            .resizable()
                            .scaledToFill()
                            .frame(width: 40, height: 40)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .blur(radius: 2)
                            .opacity(0.6)
                    } else {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color(.tertiarySystemGroupedBackground))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.system(size: 16))
                                    .foregroundStyle(.gray)
                            )
                            .blur(radius: 2)
                            .opacity(0.6)
                    }

                    Text("•••")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .shadow(radius: 2)
                }
                .frame(width: 40, height: 40)
                .onTapGesture {
                    selectedPhotoIndex = 2
                    showingPhotoOverlay = true
                }
            }
        }
    }

    private var manualCompletionButton: some View {
        Button {
            model.toggleSubtaskCompletion(subtask.id)
        } label: {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 24))
                .foregroundStyle(.gray)
        }
        .buttonStyle(.plain)
    }

    private var rowShape: UnevenRoundedRectangle {
        UnevenRoundedRectangle(
            topLeadingRadius: index == 0 ? 12 : 0,
            bottomLeadingRadius: isLast ? 12 : 0,
            bottomTrailingRadius: isLast ? 12 : 0,
            topTrailingRadius: index == 0 ? 12 : 0,
            style: .continuous
        )
    }

}

