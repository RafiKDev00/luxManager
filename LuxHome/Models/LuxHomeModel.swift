//
//  LuxHomeModel.swift
//  LuxHome
//
//  Created by RJ Kigner on 12/21/25.
//

import Foundation
import SwiftUI

@Observable
class LuxHomeModel {
    // MARK: - Shared Instance
    static let shared = LuxHomeModel()

    // MARK: - Published State
    var tasks: [LuxTask] = []
    var subtasks: [LuxSubTask] = []
    var isLoading: Bool = false
    var errorMessage: String?
    var showToast: Bool = false
    var toastMessage: String = ""

    // MARK: - Computed Properties

    // Overdue tasks
    var overdueTasks: [LuxTask] {
        tasks.filter { $0.status == "Overdue" && !$0.isCompleted }
    }

    // Today's tasks (excluding overdue)
    var todayTasks: [LuxTask] {
        tasks.filter { task in
            !task.isCompleted &&
            task.status != "Overdue" &&
            (task.status == "Active" || task.status == "To Do")
        }
    }

    // Week tasks (excluding today's tasks and overdue)
    var weekTasks: [LuxTask] {
        tasks.filter { task in
            !task.isCompleted &&
            task.status != "Overdue" &&
            task.status != "Active" &&
            task.status != "To Do" &&
            isThisWeek(task.lastCompletedDate)
        }
    }

    var todayTasksCompleted: Int {
        tasks.filter { $0.isCompleted && isToday($0.lastCompletedDate) }.count
    }

    var todayTasksTotal: Int {
        todayTasks.count
    }

    var weekTasksCompleted: Int {
        tasks.filter { $0.isCompleted && isThisWeek($0.lastCompletedDate) }.count
    }

    var weekTasksTotal: Int {
        tasks.count
    }

    // MARK: - Initialization
    private init() {
        loadSampleData()
    }

    // MARK: - Sample Data (For Previews & Development)
    static var sampleTasks: [LuxTask] {
        [
            LuxTask(
                name: "Install New Kitchen Cabinets",
                status: "To Do",
                description: "Remove old cabinets and install new ones in the kitchen",
                lastCompletedDate: nil,
                isCompleted: false,
                completedSubtasks: 0,
                totalSubtasks: 8
            ),
            LuxTask(
                name: "Paint Living Room Walls",
                status: "Active",
                description: "Apply two coats of paint to all living room walls",
                lastCompletedDate: Date().addingTimeInterval(-86400 * 5),
                isCompleted: false,
                completedSubtasks: 3,
                totalSubtasks: 6
            ),
            LuxTask(
                name: "Fix Leaking Bathroom Faucet",
                status: "Overdue",
                description: "Replace washer and tighten connections on master bathroom sink",
                lastCompletedDate: Date().addingTimeInterval(-86400 * 30),
                isCompleted: false,
                completedSubtasks: 1,
                totalSubtasks: 4
            ),
            LuxTask(
                name: "Schedule Electrical Inspection",
                status: "Waiting",
                description: "Contact city inspector for final electrical walkthrough",
                lastCompletedDate: Date().addingTimeInterval(-86400 * 3),
                isCompleted: false,
                completedSubtasks: 3,
                totalSubtasks: 5
            ),
            LuxTask(
                name: "Install New Light Fixtures",
                status: "Active",
                description: "Replace all bedroom light fixtures with new LED models",
                lastCompletedDate: Date().addingTimeInterval(-86400 * 2),
                isCompleted: false,
                completedSubtasks: 2,
                totalSubtasks: 7
            ),
            LuxTask(
                name: "Order New Appliances",
                status: "Waiting",
                description: "Research and order new kitchen appliances",
                lastCompletedDate: Date().addingTimeInterval(-86400 * 4),
                isCompleted: false,
                completedSubtasks: 1,
                totalSubtasks: 3
            ),
            LuxTask(
                name: "Plan Landscaping Project",
                status: "Waiting",
                description: "Design new backyard landscaping layout",
                lastCompletedDate: Date().addingTimeInterval(-86400 * 6),
                isCompleted: false,
                completedSubtasks: 0,
                totalSubtasks: 4
            ),
            LuxTask(
                name: "Get Roof Inspection",
                status: "Waiting",
                description: "Schedule professional roof inspection before winter",
                lastCompletedDate: Date().addingTimeInterval(-86400 * 5),
                isCompleted: false,
                completedSubtasks: 0,
                totalSubtasks: 2
            )
        ]
    }

    // MARK: - Data Methods
    func loadSampleData() {
        tasks = LuxHomeModel.sampleTasks
    }

    // MARK: - Task Management
    func toggleTaskCompletion(_ taskId: UUID) {
        if let index = tasks.firstIndex(where: { $0.id == taskId }) {
            tasks[index].isCompleted.toggle()
            if tasks[index].isCompleted {
                tasks[index].lastCompletedDate = Date()
            }
        }
    }

    func updateTask(_ task: LuxTask) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
        }
    }

    func addTask(_ task: LuxTask) {
        tasks.append(task)
    }

    func deleteTask(_ taskId: UUID) {
        tasks.removeAll { $0.id == taskId }
    }

    // MARK: - SubTask Management
    func getSubtasks(for taskId: UUID) -> [LuxSubTask] {
        subtasks.filter { $0.taskId == taskId }
    }

    func addSubtask(_ subtask: LuxSubTask) {
        subtasks.append(subtask)
        updateTaskSubtaskCounts(subtask.taskId)
    }

    func toggleSubtaskCompletion(_ subtaskId: UUID) {
        if let index = subtasks.firstIndex(where: { $0.id == subtaskId }) {
            subtasks[index].isCompleted.toggle()
            updateTaskSubtaskCounts(subtasks[index].taskId)
        }
    }

    func deleteSubtask(_ subtaskId: UUID) {
        if let subtask = subtasks.first(where: { $0.id == subtaskId }) {
            let taskId = subtask.taskId
            subtasks.removeAll { $0.id == subtaskId }
            updateTaskSubtaskCounts(taskId)
        }
    }

    private func updateTaskSubtaskCounts(_ taskId: UUID) {
        if let index = tasks.firstIndex(where: { $0.id == taskId }) {
            let taskSubtasks = subtasks.filter { $0.taskId == taskId }
            tasks[index].totalSubtasks = taskSubtasks.count
            tasks[index].completedSubtasks = taskSubtasks.filter { $0.isCompleted }.count
        }
    }

    // MARK: - Network Methods (Future Backend Integration)
    func fetchTasks() async {
        isLoading = true
        defer { isLoading = false }

        // TODO: Replace with actual API call
        // Example:
        // do {
        //     let response = try await NetworkService.fetchTasks()
        //     tasks = response
        // } catch {
        //     errorMessage = error.localizedDescription
        // }

        // For now, just use sample data
        await MainActor.run {
            loadSampleData()
        }
    }

    func saveTask(_ task: LuxTask) async {
        isLoading = true
        defer { isLoading = false }

        // TODO: Replace with actual API call
        // Example:
        // do {
        //     try await NetworkService.saveTask(task)
        //     await fetchTasks()
        //     showToast(message: "Task saved successfully")
        // } catch {
        //     errorMessage = error.localizedDescription
        // }

        await MainActor.run {
            updateTask(task)
            showToast(message: "Task saved successfully")
        }
    }

    // MARK: - Helper Methods
    func showToast(message: String) {
        toastMessage = message
        showToast = true

        _Concurrency.Task {
            try? await _Concurrency.Task.sleep(nanoseconds: 2_000_000_000)
            await MainActor.run {
                showToast = false
            }
        }
    }

    private func isToday(_ date: Date?) -> Bool {
        guard let date = date else { return false }
        return Calendar.current.isDateInToday(date)
    }

    private func isThisWeek(_ date: Date?) -> Bool {
        guard let date = date else { return false }
        let calendar = Calendar.current
        let now = Date()
        return calendar.isDate(date, equalTo: now, toGranularity: .weekOfYear)
    }
}
