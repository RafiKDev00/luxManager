//
//  SubTaskView.swift
//  LuxHome
//
//  Created by RJ Kigner on 12/18/25.
//

import SwiftUI

struct SubTaskView: View {
    @Binding var task: LuxTask

    var body: some View {
        VStack {
            Text("Hello World")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("Task Details")
    }
}

#Preview {
    NavigationStack {
        SubTaskView(task: .constant(
            LuxTask(
                name: "Install New Kitchen Cabinets",
                status: "To Do",
                description: "Remove old cabinets and install new ones in the kitchen",
                lastCompletedDate: nil,
                isCompleted: false
            )
        ))
    }
}
