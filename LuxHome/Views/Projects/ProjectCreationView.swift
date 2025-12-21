//
//  ProjectCreationView.swift
//  LuxHome
//
//  Created by RJ Kigner on 12/21/25.
//

import SwiftUI

struct ProjectCreationView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(LuxHomeModel.self) private var model

    @State private var projectName: String = ""
    @State private var description: String = ""
    @State private var dueDate: Date = Date()
    @State private var nextStep: String = ""

    var body: some View {
        NavigationStack {
            Form {
                projectDetailsSection
                schedulingSection
                nextStepSection
            }
            .safeAreaBar(edge: .top, spacing: 0) {
                topBar
            }
        }
    }

    private var projectDetailsSection: some View {
        Section {
            TextField("Project Name", text: $projectName)
                .font(.headline)

            TextField("Description", text: $description, axis: .vertical)
                .lineLimit(3...6)
        } header: {
            Text("Project Details")
        }
    }

    private var schedulingSection: some View {
        Section {
            DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                .tint(.pink)
        } header: {
            Text("Timeline")
        }
    }

    private var nextStepSection: some View {
        Section {
            TextField("Next Step", text: $nextStep, axis: .vertical)
                .lineLimit(2...4)
        } header: {
            Text("Next Step (Optional)")
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
        Text("New Project")
            .font(.system(size: 24, weight: .bold))
    }

    private var saveButton: some View {
        Button {
            saveProject()
        } label: {
            Image(systemName: "checkmark")
        }
        .buttonStyle(IconButtonStyle(type: .check))
        .disabled(projectName.isEmpty || description.isEmpty)
        .opacity(projectName.isEmpty || description.isEmpty ? 0.8 : 1.0)
        .padding(.trailing, 16)
    }

    private func saveProject() {
        model.createProject(
            name: projectName,
            description: description,
            dueDate: dueDate,
            nextStep: nextStep
        )
        dismiss()
    }
}

#Preview {
    @Previewable @State var showingSheet = true

    Color.clear
        .sheet(isPresented: $showingSheet) {
            ProjectCreationView()
                .environment(LuxHomeModel.shared)
        }
}
