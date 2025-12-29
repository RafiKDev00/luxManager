//
//  HistoryActionIcon.swift
//  LuxHome
//
//  Created by RJ Kigner on 12/23/25.
//

import SwiftUI

struct HistoryActionIcon: View {
    let action: HistoryAction

    var body: some View {
        Group {
            switch action {
            case .created:
                Image(systemName: "plus.circle.fill")
                    .foregroundStyle(.green)
            case .completed:
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.orange)
            case .edited:
                Image(systemName: "pencil.circle.fill")
                    .foregroundStyle(.blue)
            case .deleted:
                Image(systemName: "trash.circle.fill")
                    .foregroundStyle(.red)
            case .photoAdded:
                Image(systemName: "camera.circle.fill")
                    .foregroundStyle(.purple)
            case .photoDeleted:
                Image(systemName: "photo.circle.fill")
                    .foregroundStyle(.red)
            case .contacted:
                Image(systemName: "phone.circle.fill")
                    .foregroundStyle(.orange)
            }
        }
        .font(.system(size: 24))
    }
}

#Preview("Created") {
    HistoryActionIcon(action: .created)
}

#Preview("Completed") {
    HistoryActionIcon(action: .completed)
}

#Preview("Edited") {
    HistoryActionIcon(action: .edited)
}

#Preview("Deleted") {
    HistoryActionIcon(action: .deleted)
}

#Preview("Photo Added") {
    HistoryActionIcon(action: .photoAdded)
}
