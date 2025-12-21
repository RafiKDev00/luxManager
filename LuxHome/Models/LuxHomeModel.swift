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
    var projects: [LuxProject] = []
    var workers: [LuxWorker] = []
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
            task.status != "To Do"
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
    static let sampleTaskId1 = UUID()
    static let sampleTaskId2 = UUID()
    static let sampleTaskId3 = UUID()
    static let sampleTaskId4 = UUID()
    static let sampleTaskId5 = UUID()
    static let sampleTaskId6 = UUID()
    static let sampleTaskId7 = UUID()
    static let sampleTaskId8 = UUID()

    static var sampleTasks: [LuxTask] {
        [
            LuxTask(
                id: sampleTaskId1,
                name: "Install New Kitchen Cabinets",
                status: "To Do",
                description: "Remove old cabinets and install new ones in the kitchen",
                lastCompletedDate: nil,
                isCompleted: false,
                completedSubtasks: 0,
                totalSubtasks: 8
            ),
            LuxTask(
                id: sampleTaskId2,
                name: "Paint Living Room Walls",
                status: "Active",
                description: "Apply two coats of paint to all living room walls",
                lastCompletedDate: Date().addingTimeInterval(-86400 * 5),
                isCompleted: false,
                completedSubtasks: 3,
                totalSubtasks: 6
            ),
            LuxTask(
                id: sampleTaskId3,
                name: "Fix Leaking Bathroom Faucet",
                status: "Overdue",
                description: "Replace washer and tighten connections on master bathroom sink",
                lastCompletedDate: Date().addingTimeInterval(-86400 * 30),
                isCompleted: false,
                completedSubtasks: 1,
                totalSubtasks: 4
            ),
            LuxTask(
                id: sampleTaskId4,
                name: "Schedule Electrical Inspection",
                status: "Active",
                description: "Contact city inspector for final electrical walkthrough",
                lastCompletedDate: Date(),
                isCompleted: true,
                completedSubtasks: 3,
                totalSubtasks: 3
            ),
            LuxTask(
                id: sampleTaskId6,
                name: "Install New Light Fixtures",
                status: "Active",
                description: "Replace all bedroom light fixtures with new LED models",
                lastCompletedDate: Date().addingTimeInterval(-86400 * 2),
                isCompleted: false,
                completedSubtasks: 0,
                totalSubtasks: 1
            ),
            LuxTask(
                id: sampleTaskId7,
                name: "Order New Appliances",
                status: "Waiting",
                description: "Research and order new kitchen appliances",
                lastCompletedDate: Date().addingTimeInterval(-86400 * 4),
                isCompleted: false,
                completedSubtasks: 0,
                totalSubtasks: 1
            ),
            LuxTask(
                id: sampleTaskId8,
                name: "Plan Landscaping Project",
                status: "Waiting",
                description: "Design new backyard landscaping layout",
                lastCompletedDate: Date().addingTimeInterval(-86400 * 6),
                isCompleted: false,
                completedSubtasks: 0,
                totalSubtasks: 1
            ),
            LuxTask(
                id: sampleTaskId5,
                name: "Get Roof Inspection",
                status: "Waiting",
                description: "Schedule professional roof inspection before winter",
                lastCompletedDate: Date().addingTimeInterval(-86400 * 5),
                isCompleted: false,
                completedSubtasks: 0,
                totalSubtasks: 1
            )
        ]
    }

    static var sampleProjects: [LuxProject] {
        [
            LuxProject(
                name: "Garden Remodel",
                status: "In Progress",
                description: "A comprehensive renovation of the backyard garden, including new landscaping, irrigation system, and a custom-built patio.",
                dueDate: Calendar.current.date(byAdding: .month, value: 2, to: Date())!,
                nextStep: "Approve final plant selections and confirm irrigation system layout.",
                photoURLs: ["photo1", "photo2", "photo3"],
                progressLog: [
                    ProgressLogEntry(
                        date: Calendar.current.date(byAdding: .day, value: -8, to: Date())!,
                        text: "Initial consultation and site assessment completed. Project scope defined and approved by owner."
                    ),
                    ProgressLogEntry(
                        date: Calendar.current.date(byAdding: .day, value: -6, to: Date())!,
                        text: "Demolition of old patio and removal of existing shrubbery. Area cleared for new construction.",
                        photoURL: "demolition_photo"
                    ),
                    ProgressLogEntry(
                        date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
                        text: "Foundation for the new patio laid. Materials for irrigation system delivered on site."
                    ),
                    ProgressLogEntry(
                        date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
                        text: "Irrigation lines installed in designated areas. Initial selection of drought-resistant plants received for review.",
                        photoURL: "irrigation_photo"
                    )
                ]
            ),
            LuxProject(
                name: "Kitchen Renovation",
                status: "In Progress",
                description: "Complete kitchen overhaul including new cabinets, countertops, appliances, and updated electrical work.",
                dueDate: Calendar.current.date(byAdding: .month, value: 1, to: Date())!,
                nextStep: "Install new countertops and backsplash.",
                photoURLs: ["kitchen1", "kitchen2"],
                progressLog: [
                    ProgressLogEntry(
                        date: Calendar.current.date(byAdding: .day, value: -5, to: Date())!,
                        text: "Old cabinets removed and walls patched."
                    ),
                    ProgressLogEntry(
                        date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
                        text: "New cabinets installed and leveled.",
                        photoURL: "cabinets_photo"
                    )
                ]
            ),
            LuxProject(
                name: "Basement Finishing",
                status: "On Hold",
                description: "Transform unfinished basement into a family room with home theater setup.",
                dueDate: Calendar.current.date(byAdding: .month, value: 4, to: Date())!,
                nextStep: "Wait for permit approval from city.",
                photoURLs: [],
                progressLog: [
                    ProgressLogEntry(
                        date: Calendar.current.date(byAdding: .day, value: -10, to: Date())!,
                        text: "Permit application submitted to city planning department."
                    )
                ]
            )
        ]
    }

    static var sampleWorkers: [LuxWorker] {
        [
            LuxWorker(
                name: "Maria Rodriguez",
                company: "GreenScape Gardeners",
                phone: "(555) 123-4567",
                email: "maria@greenscape.com",
                specialization: "Gardener",
                serviceTypes: ["Gardener", "Landscaping", "Tree Trimming"],
                scheduleType: .weekly,
                isScheduled: true,
                nextVisit: Calendar.current.date(byAdding: .day, value: 5, to: Date()),
                scheduledVisits: [],
                photoURL: nil
            ),
            LuxWorker(
                name: "John Smith",
                company: "Sparkle Cleaners",
                phone: "(555) 987-6543",
                specialization: "Cleaner",
                serviceTypes: ["Cleaner", "Deep Cleaning", "Window Washing"],
                scheduleType: .biWeekly,
                isScheduled: true,
                nextVisit: Calendar.current.date(byAdding: .day, value: 6, to: Date()),
                scheduledVisits: []
            ),
            LuxWorker(
                name: "Michael Chen",
                company: "AquaPool Services",
                phone: "(555) 234-5678",
                specialization: "Pool Service",
                serviceTypes: ["Pool Service", "Equipment Repair", "Water Testing"],
                scheduleType: .weekly,
                isScheduled: false,
                nextVisit: Calendar.current.date(byAdding: .day, value: 7, to: Date()),
                scheduledVisits: []
            ),
            LuxWorker(
                name: "Sarah Lee",
                company: "Comfort HVAC Solutions",
                phone: "(555) 345-6789",
                specialization: "HVAC Tech",
                serviceTypes: ["HVAC Tech", "AC Repair", "Heating Maintenance"],
                scheduleType: .monthly,
                isScheduled: false,
                nextVisit: Calendar.current.date(byAdding: .day, value: 8, to: Date()),
                scheduledVisits: []
            )
        ]
    }

    // MARK: - Data Methods
    func loadSampleData() {
        tasks = LuxHomeModel.sampleTasks
        subtasks = LuxHomeModel.sampleSubtasks
        projects = LuxHomeModel.sampleProjects
        workers = LuxHomeModel.sampleWorkers
    }

    static var sampleSubtasks: [LuxSubTask] {
        [
            // Subtasks for "Install New Kitchen Cabinets"
            LuxSubTask(name: "Remove old cabinet doors", isCompleted: false, taskId: sampleTaskId1),
            LuxSubTask(name: "Disconnect plumbing and electrical", isCompleted: false, taskId: sampleTaskId1),
            LuxSubTask(name: "Remove old cabinet boxes", isCompleted: false, taskId: sampleTaskId1),
            LuxSubTask(name: "Patch and paint walls", isCompleted: false, taskId: sampleTaskId1),
            LuxSubTask(name: "Install new cabinet boxes", isCompleted: false, taskId: sampleTaskId1),
            LuxSubTask(name: "Level and secure cabinets", isCompleted: false, taskId: sampleTaskId1),
            LuxSubTask(name: "Install cabinet doors and hardware", isCompleted: false, taskId: sampleTaskId1),
            LuxSubTask(name: "Reconnect plumbing and electrical", isCompleted: false, taskId: sampleTaskId1),

            // Subtasks for "Paint Living Room Walls"
            LuxSubTask(name: "Move furniture to center", isCompleted: true, taskId: sampleTaskId2, photoURL: "sample://photo1"),
            LuxSubTask(name: "Tape edges and trim", isCompleted: true, taskId: sampleTaskId2),
            LuxSubTask(name: "Apply primer coat", isCompleted: true, taskId: sampleTaskId2, photoURL: "sample://photo2"),
            LuxSubTask(name: "Apply first paint coat", isCompleted: false, taskId: sampleTaskId2),
            LuxSubTask(name: "Apply second paint coat", isCompleted: false, taskId: sampleTaskId2),
            LuxSubTask(name: "Clean up and move furniture back", isCompleted: false, taskId: sampleTaskId2),

            // Subtasks for "Fix Leaking Bathroom Faucet"
            LuxSubTask(name: "Turn off water supply", isCompleted: true, taskId: sampleTaskId3),
            LuxSubTask(name: "Disassemble faucet", isCompleted: false, taskId: sampleTaskId3),
            LuxSubTask(name: "Replace washer and O-rings", isCompleted: false, taskId: sampleTaskId3),
            LuxSubTask(name: "Reassemble and test for leaks", isCompleted: false, taskId: sampleTaskId3),

            // Subtasks for "Schedule Electrical Inspection" (all completed)
            LuxSubTask(name: "Call city inspector", isCompleted: true, taskId: sampleTaskId4, photoURL: "sample://photo3"),
            LuxSubTask(name: "Schedule appointment", isCompleted: true, taskId: sampleTaskId4),
            LuxSubTask(name: "Prepare documentation", isCompleted: true, taskId: sampleTaskId4, photoURL: "sample://photo4"),

            // Single subtasks with same name as task (for tasks with no custom subtasks)
            LuxSubTask(name: "Get Roof Inspection", isCompleted: false, taskId: sampleTaskId5),
            LuxSubTask(name: "Install New Light Fixtures", isCompleted: false, taskId: sampleTaskId6),
            LuxSubTask(name: "Order New Appliances", isCompleted: false, taskId: sampleTaskId7),
            LuxSubTask(name: "Plan Landscaping Project", isCompleted: false, taskId: sampleTaskId8)
        ]
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

    func createTask(name: String, dueDay: String, isRecurring: Bool, subtaskNames: [String]) {
        let finalSubtaskNames = subtaskNames.isEmpty ? [name] : subtaskNames

        let newTask = LuxTask(
            name: name,
            status: "To Do",
            description: "Due \(dueDay)\(isRecurring ? " (Recurring)" : "")",
            lastCompletedDate: nil,
            isCompleted: false,
            completedSubtasks: 0,
            totalSubtasks: finalSubtaskNames.count
        )

        tasks.append(newTask)

        for subtaskName in finalSubtaskNames {
            let subtask = LuxSubTask(
                name: subtaskName,
                isCompleted: false,
                taskId: newTask.id
            )
            subtasks.append(subtask)
        }
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

    func updateSubtaskPhoto(_ subtaskId: UUID, photoURL: String) {
        if let index = subtasks.firstIndex(where: { $0.id == subtaskId }) {
            subtasks[index].photoURL = photoURL
            subtasks[index].isCompleted = true
            updateTaskSubtaskCounts(subtasks[index].taskId)
        }
    }

    private func updateTaskSubtaskCounts(_ taskId: UUID) {
        if let index = tasks.firstIndex(where: { $0.id == taskId }) {
            let taskSubtasks = subtasks.filter { $0.taskId == taskId }
            let completedCount = taskSubtasks.filter { $0.isCompleted }.count

            tasks[index].totalSubtasks = taskSubtasks.count
            tasks[index].completedSubtasks = completedCount

            if taskSubtasks.count > 0 && completedCount == taskSubtasks.count {
                tasks[index].isCompleted = true
                tasks[index].lastCompletedDate = Date()
            } else {
                tasks[index].isCompleted = false
            }
        }
    }

    // MARK: - Project Management
    func createProject(name: String, description: String, dueDate: Date, nextStep: String) {
        let newProject = LuxProject(
            name: name,
            description: description,
            dueDate: dueDate,
            nextStep: nextStep
        )
        projects.append(newProject)
    }

    func addPhotoToProject(_ projectId: UUID, photoURL: String) {
        if let index = projects.firstIndex(where: { $0.id == projectId }) {
            projects[index].photoURLs.append(photoURL)
        }
    }

    func addProgressLogEntry(to projectId: UUID, text: String, photoURL: String?) {
        if let index = projects.firstIndex(where: { $0.id == projectId }) {
            let entry = ProgressLogEntry(
                date: Date(),
                text: text,
                photoURL: photoURL
            )
            projects[index].progressLog.insert(entry, at: 0)
        }
    }

    func updateProjectNextStep(_ projectId: UUID, nextStep: String) {
        if let index = projects.firstIndex(where: { $0.id == projectId }) {
            projects[index].nextStep = nextStep
        }
    }

    // MARK: - Worker Management
    func createWorker(name: String, company: String, phone: String, email: String?, specialization: String, serviceTypes: [String], scheduleType: ScheduleType) {
        let newWorker = LuxWorker(
            name: name,
            company: company,
            phone: phone,
            email: email,
            specialization: specialization,
            serviceTypes: serviceTypes,
            scheduleType: scheduleType
        )
        workers.append(newWorker)
    }

    func toggleWorkerSchedule(_ workerId: UUID, isScheduled: Bool) {
        if let index = workers.firstIndex(where: { $0.id == workerId }) {
            workers[index].isScheduled = isScheduled
        }
    }

    func addScheduledVisit(to workerId: UUID, visit: ScheduledVisit) {
        if let index = workers.firstIndex(where: { $0.id == workerId }) {
            workers[index].scheduledVisits.append(visit)
            if let firstVisit = workers[index].scheduledVisits.sorted(by: { $0.date < $1.date }).first {
                workers[index].nextVisit = firstVisit.date
            }
        }
    }

    func toggleVisitCompletion(_ workerId: UUID, visitId: UUID) {
        if let workerIndex = workers.firstIndex(where: { $0.id == workerId }),
           let visitIndex = workers[workerIndex].scheduledVisits.firstIndex(where: { $0.id == visitId }) {
            workers[workerIndex].scheduledVisits[visitIndex].isDone.toggle()
        }
    }

    func updateWorker(_ workerId: UUID, name: String, company: String, phone: String, email: String?, specialization: String, serviceTypes: [String]) {
        if let index = workers.firstIndex(where: { $0.id == workerId }) {
            workers[index].name = name
            workers[index].company = company
            workers[index].phone = phone
            workers[index].email = email
            workers[index].specialization = specialization
            workers[index].serviceTypes = serviceTypes
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
