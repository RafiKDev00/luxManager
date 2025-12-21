//
//  WorkersView.swift
//  LuxHome
//
//  Created by RJ Kigner on 12/21/25.
//

import SwiftUI

struct WorkersView: View {
    @Environment(LuxHomeModel.self) private var model
    @State private var showingWorkerCreation = false

    var body: some View {
        NavigationStack {
            WorkerListView()
                .safeAreaBar(edge: .bottom) {
                    HStack {
                        Spacer()
                        Button {
                            showingWorkerCreation = true
                        } label: {
                            Image(systemName: "plus")
                        }
                        .buttonStyle(IconButtonStyle(type: .plus))
                        .padding(.trailing, 16)
                        .padding(.bottom, 8)
                    }
                    .background(Color.clear)
                }
                .sheet(isPresented: $showingWorkerCreation) {
                    WorkerCreationView()
                        .environment(model)
                }
        }
    }
}

#Preview {
    WorkersView()
        .environment(LuxHomeModel.shared)
}
