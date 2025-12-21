//
//  HomeView.swift
//  LuxHome
//
//  Created by RJ Kigner on 12/18/25.
//

import SwiftUI

struct HomeView: View {

    var body: some View{
        NavigationStack {
            VStack{
                TaskList
                    .ignoresSafeArea(edges: .bottom)
                    .safeAreaBar(edge: .top){
                        HeaderArea
                    }
            }
        }
    }

    var TaskList: some View{
        TaskView()
    }

    var HeaderArea: some View{
        VStack(alignment: .leading, spacing: 8) {
            HStack() {
                Image(systemName: "house.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 24, height: 24)
                    .background(
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [.blue, .blue.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
                
                Text("Weekly Tasks")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.horizontal, 4)


                Spacer()

                Button(action: {}) {}
                    .buttonStyle(.iconEllipsis)
            }
            .padding(.horizontal)
            .padding(.top, 8)

                    }
        .frame(maxWidth: .infinity)
    }
}

struct RootTabView: View {
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house") {
                HomeView()
            }
            .badge(2)

            Tab("Projects", systemImage: "checklist.unchecked") {
                Text("Projects View")
            }
            .badge("!")

            Tab("Workers", systemImage: "person.2") {
                Text("Workers View")
            }
            .badge("!")

            Tab("Add", systemImage: "plus.app") {
                Text("Add View")
            }
        }
    }
}

#Preview {
    RootTabView()
}


//Weekly Tasks and all things due that week show up on weekly tasks view.
