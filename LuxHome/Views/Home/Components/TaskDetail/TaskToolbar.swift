//
//  TaskToolbar.swift
//  LuxHome
//
//  Created by RJ Kigner on 12/24/25.
//

import SwiftUI

struct TaskToolbar: ToolbarContent {
    @Binding var isEditMode: Bool
    let onDeleteTap: () -> Void

    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                isEditMode.toggle()
            } label: {
                Text(isEditMode ? "Done" : "Edit")
            }
        }

        if isEditMode {
            ToolbarItem(placement: .topBarLeading) {
                Button(role: .destructive) {
                    onDeleteTap()
                } label: {
                    Text("Delete Task")
                        .foregroundStyle(.red)
                }
            }
        }
    }
}
