//
//  ToDobject.swift
//  LuxHome
//
//  Created by RJ  Kigner on 12/19/25.
//

import SwiftUI

struct ToDobject: View {
    @Environment(LuxHomeModel.self) private var model

    var body: some View {
        ZStack(alignment: .top) {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                StatusHeaderView()

                List {
                    Section {
                        TaskRowView(tasks: orderedTasks)
                    } header: {
                        SectionHeaderView(title: "Tasks", color: .primary)
                    }
                }
                .listStyle(.plain)
                .listSectionSpacing(0)
                .scrollContentBackground(.hidden)
                .padding(.top, -22)
            }
        }
    }

    private var orderedTasks: [LuxTask] {
        model.tasks.sorted { lhs, rhs in
            if lhs.isCompleted != rhs.isCompleted {
                return !lhs.isCompleted
            }
            return lhs.createdAt > rhs.createdAt
        }
    }
}

#Preview {
    ToDobject()
        .environment(LuxHomeModel.shared)
}


/***
 
 I think Arranging by dates is a good idea.
 Realistically. One page. Week tasks with today tasks prioritized
 you add with a plus button.
 Tasks can have a chec list with an uplaod button
 THen there's a long term tasks thing
 and a calander so you can get a broad overview. And a general contacts
 
 
 Top of dashboard is a completion bar for today/ week tasks.
 
 
 So tab bar on bottom
 calender, dashbaord/recurring, long term, people
 ellipse button on top for like user details
 
 
 
 
 
 ***/
