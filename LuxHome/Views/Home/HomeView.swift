//
//  HomeView.swift
//  LuxHome
//
//  Created by RJ Kigner on 12/18/25.
//

import SwiftUI

struct HomeView: View {
    @Environment(LuxHomeModel.self) private var model
    @State private var showingTaskCreation = false

    var body: some View{
        NavigationStack {
            ToDobject()
                .safeAreaBar(edge: .bottom) {
                    HStack {
                        Spacer()
                        Button {
                            showingTaskCreation = true
                        } label: {
                            Image(systemName: "plus")
                        }
                        .buttonStyle(IconButtonStyle(type: .plus))
                        .padding(.trailing, 16)
                        .padding(.bottom, 8)
                    }
                    .background(Color.clear)
                }
                .sheet(isPresented: $showingTaskCreation) {
                    ScheduledTaskCreationView()
                        .environment(model)
                }
        }
    }
}

struct RootTabView: View {
    @Environment(LuxHomeModel.self) private var model

    var totalTaskCount: Int {
        model.incompleteTasks.count
    }

    var body: some View {
        TabView {
            Tab("Home", systemImage: "house") {
                HomeView()
            }
            .badge(totalTaskCount)

            Tab("Projects", systemImage: "checklist.unchecked") {
                ProjectView()
            }

            Tab("Workers", systemImage: "person.2") {
                WorkersView()
            }

            Tab("History", systemImage: "clock") {
                HistoryView()
            }
        }
    }
}

#Preview {
    RootTabView()
        .environment(LuxHomeModel.shared)
}


// Weekly Tasks and all things due that week show up on weekly tasks view.
