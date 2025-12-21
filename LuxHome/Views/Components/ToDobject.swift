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
                EngravedFont(text: "Status", font: .system(size: 40, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .background(Color(.systemGroupedBackground))

                List {
                    // Overdue section - only shows if there are overdue tasks
                    if !model.overdueTasks.isEmpty {
                        Section {
                            taskRows(tasks: model.overdueTasks)
                        } header: {
                            sectionHeader(title: "Overdue", color: .red)
                        }
                    }

                    // Today's Tasks section
                    Section {
                        taskRows(tasks: model.todayTasks)
                    } header: {
                        sectionHeader(title: "Today's Tasks", color: .primary)
                    }

                    // Week Tasks section (excluding today's tasks)
                    if !model.weekTasks.isEmpty {
                        Section {
                            taskRows(tasks: model.weekTasks)
                        } header: {
                            sectionHeader(title: "Week Tasks", color: .primary)
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
    }

    private func sectionHeader(title: String, color: Color = .primary) -> some View {
        Text(title)
            .font(.title2)
            .fontWeight(.bold)
            .foregroundStyle(color)
            .textCase(nil)
    }

    private func taskRows(tasks: [LuxTask]) -> some View {
        ForEach(Array(tasks.enumerated()), id: \.element.id) { index, task in
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.name)
                        .font(.headline)
                    Text(task.status)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(task.isCompleted ? .blue : .gray)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color(.secondarySystemGroupedBackground))
            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
            .listRowBackground(Color.clear)
            .listRowSeparator(index == tasks.count - 1 ? .hidden : .visible, edges: .bottom)
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: index == 0 ? 12 : 0,
                    bottomLeadingRadius: index == tasks.count - 1 ? 12 : 0,
                    bottomTrailingRadius: index == tasks.count - 1 ? 12 : 0,
                    topTrailingRadius: index == 0 ? 12 : 0,
                    style: .continuous
                )
            )
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
