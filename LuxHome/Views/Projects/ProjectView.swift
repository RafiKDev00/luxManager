//
//  ProjectView.swift
//  LuxHome
//
//  Created by RJ  Kigner on 12/21/25.
//

import SwiftUI

struct ProjectView: View {
    @Environment(LuxHomeModel.self) private var model
    @State private var showingProjectCreation = false

    var body: some View {
        NavigationStack {
            ProjectListView()
                .safeAreaBar(edge: .bottom) {
                    HStack {
                        Spacer()
                        Button {
                            showingProjectCreation = true
                        } label: {
                            Image(systemName: "plus")
                        }
                        .buttonStyle(IconButtonStyle(type: .plus))
                        .padding(.trailing, 16)
                        .padding(.bottom, 8)
                    }
                    .background(Color.clear)
                }
                .sheet(isPresented: $showingProjectCreation) {
                    ProjectCreationView()
                        .environment(model)
                }
        }
    }
}

#Preview {
    ProjectView()
        .environment(LuxHomeModel.shared)
}
