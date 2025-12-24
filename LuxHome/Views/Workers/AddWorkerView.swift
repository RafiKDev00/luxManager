//
//  AddWorkerView.swift
//  LuxHome
//
//  Created by RJ Kigner on 12/24/25.
//

import SwiftUI

struct AddWorkerView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("New Worker")
                    .font(.title2.weight(.bold))

                Text("Stub form for adding a worker. Suggestion: mirror the fields from the worker roster (name, company, phone, email, specialization, services, schedule). Save should add to LuxHomeModel and dismiss back to the project workflow.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                    .padding()

                Spacer()
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { dismiss() }
                        .disabled(true) // Placeholder
                }
            }
        }
    }
}

#Preview {
    AddWorkerView()
}
