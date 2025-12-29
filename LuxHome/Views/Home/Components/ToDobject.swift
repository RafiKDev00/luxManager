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

                if groupedTasks.isEmpty {
                    TasksEmptyStateView()
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(groupedTasks.keys.sorted(by: sortSections), id: \.self) { key in
                                VStack(alignment: .leading, spacing: 12) {
                                    sectionHeader(for: key, tasks: groupedTasks[key] ?? [])
                                        .padding(.horizontal, 16)

                                    TaskRowView(tasks: sortedTasksInGroup(groupedTasks[key] ?? []))
                                }
                            }
                        }
                        .padding(.top, 16)
                        .padding(.bottom, 32)
                    }
                }
            }
        }
    }

    private var groupedTasks: [String: [LuxTask]] {
        let recurringTasks = model.tasks.filter { $0.isRecurring }
        return Dictionary(grouping: recurringTasks) { task in
            task.recurringDescription
        }
    }

    private func sortedTasksInGroup(_ tasks: [LuxTask]) -> [LuxTask] {
        tasks.sorted { lhs, rhs in
            // Completed tasks go to the bottom
            if lhs.isCompleted != rhs.isCompleted {
                return !lhs.isCompleted
            }

            // Sort by next due date
            guard let lhsDate = lhs.nextDueDate, let rhsDate = rhs.nextDueDate else {
                return false
            }
            return lhsDate < rhsDate
        }
    }

    private func sectionHeader(for key: String, tasks: [LuxTask]) -> some View {
        let incompleteTasks = tasks.filter { !$0.isCompleted }
        let nextDue = incompleteTasks.compactMap { $0.nextDueDate }.min()

        return HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(key)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
                .textCase(nil)

            if let nextDue = nextDue {
                let description = incompleteTasks
                    .first(where: { $0.nextDueDate == nextDue })?
                    .dueDateDescription() ?? ""

                Text("(Next: \(description))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .textCase(nil)
            }

            Spacer()
        }
    }

    private func sortSections(_ lhs: String, _ rhs: String) -> Bool {
        let lhsInterval = extractInterval(from: lhs)
        let rhsInterval = extractInterval(from: rhs)

        return lhsInterval < rhsInterval
    }

    private func extractInterval(from description: String) -> Int {
        // Convert to comparable number (weeks in total)
        if description.contains("Week") {
            if description.hasPrefix("Every ") {
                let components = description.components(separatedBy: " ")
                if components.count >= 2, let num = Int(components[1]) {
                    return num
                }
                return 1 // "Every Week"
            }
        } else if description.contains("Month") {
            if description.hasPrefix("Every ") {
                let components = description.components(separatedBy: " ")
                if components.count >= 2, let num = Int(components[1]) {
                    return num * 4 // Convert months to weeks for comparison
                }
                return 4 // "Every Month" = 4 weeks
            }
        }
        return 999 // Unknown, put at end
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
