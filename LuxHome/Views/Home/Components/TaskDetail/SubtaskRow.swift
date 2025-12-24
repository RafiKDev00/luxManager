//
//  SubtaskRow.swift
//  LuxHome
//
//  Created by RJ Kigner on 12/24/25.
//

import SwiftUI

struct SubtaskRow: View {
    @Environment(LuxHomeModel.self) private var model

    let subtask: LuxSubTask
    let index: Int
    let totalCount: Int
    let isEditMode: Bool
    let isLast: Bool
    let onPhotoTap: (UUID) -> Void
    let onDelete: (UUID) -> Void

    var body: some View {
        HStack {
            subtaskInfo
            Spacer()

            if isEditMode {
                swipeIndicator
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
            cameraOrCheckmarkButton

            if !subtask.isCompleted {
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

    private var cameraOrCheckmarkButton: some View {
        Button {
            handleCameraButtonTap()
        } label: {
            Image(systemName: subtask.isCompleted ? "checkmark.circle.fill" : "camera.fill")
                .font(.system(size: 24))
                .foregroundStyle(subtask.isCompleted ? .orange : .gray)
        }
        .buttonStyle(.plain)
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

    private func handleCameraButtonTap() {
        if subtask.isCompleted {
            model.toggleSubtaskCompletion(subtask.id)
        } else {
            onPhotoTap(subtask.id)
        }
    }
}
