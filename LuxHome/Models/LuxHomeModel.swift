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
    var history: [HistoryEntry] = []
    var isLoading: Bool = false
    var errorMessage: String?
    var showToast: Bool = false
    var toastMessage: String = ""

    // MARK: - Computed Properties

    // All incomplete tasks
    var incompleteTasks: [LuxTask] {
        tasks.filter { !$0.isCompleted }
    }

    // MARK: - Initialization
    private init() {
        loadSampleData()
        checkAndResetRecurringTasks()
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

    static func sampleProjects(using workers: [LuxWorker]) -> [LuxProject] {
        let mariaId = workers.count > 0 ? workers[0].id : UUID()
        let andrewId = workers.count > 1 ? workers[1].id : UUID()
        let johnId = workers.count > 3 ? workers[3].id : UUID()

        return [
            LuxProject(
                assignedWorkers: [
                    ProjectWorkerAssignment(workerId: mariaId, role: "Landscaping Lead"),
                    ProjectWorkerAssignment(workerId: johnId, role: "Irrigation")
                ],
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
                assignedWorkers: [
                    ProjectWorkerAssignment(workerId: andrewId, role: "General Contractor")
                ],
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
                assignedWorkers: [
                    ProjectWorkerAssignment(workerId: mariaId, role: "Initial inspection")
                ],
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

    static var sampleHistory: [HistoryEntry] {
        let now = Date()
        let oneHourAgo = now.addingTimeInterval(-3600)
        let twoHoursAgo = now.addingTimeInterval(-7200)
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: now)!
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: now)!
        let threeDaysAgo = Calendar.current.date(byAdding: .day, value: -3, to: now)!
        let fiveDaysAgo = Calendar.current.date(byAdding: .day, value: -5, to: now)!
        let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: now)!
        let tenDaysAgo = Calendar.current.date(byAdding: .day, value: -10, to: now)!

        return [
            HistoryEntry(
                timestamp: now,
                action: .completed,
                itemType: .subtask,
                itemName: "Apply primer coat"
            ),
            HistoryEntry(
                timestamp: oneHourAgo,
                action: .photoAdded,
                itemType: .subtask,
                itemName: "Move furniture to center",
                photoURL: "sample://photo1"
            ),
            HistoryEntry(
                timestamp: twoHoursAgo,
                action: .edited,
                itemType: .project,
                itemName: "Kitchen Renovation"
            ),
            HistoryEntry(
                timestamp: yesterday,
                action: .completed,
                itemType: .task,
                itemName: "Schedule Electrical Inspection"
            ),
            HistoryEntry(
                timestamp: yesterday.addingTimeInterval(-3600),
                action: .photoAdded,
                itemType: .project,
                itemName: "Garden Remodel",
                photoURL: "sample://irrigation_photo"
            ),
            HistoryEntry(
                timestamp: yesterday.addingTimeInterval(-7200),
                action: .created,
                itemType: .worker,
                itemName: "Maria Rodriguez"
            ),
            HistoryEntry(
                timestamp: twoDaysAgo,
                action: .deleted,
                itemType: .subtask,
                itemName: "Old subtask that was removed"
            ),
            HistoryEntry(
                timestamp: twoDaysAgo.addingTimeInterval(-3600),
                action: .created,
                itemType: .project,
                itemName: "Kitchen Renovation"
            ),
            HistoryEntry(
                timestamp: threeDaysAgo,
                action: .completed,
                itemType: .subtask,
                itemName: "Turn off water supply"
            ),
            HistoryEntry(
                timestamp: threeDaysAgo.addingTimeInterval(-1800),
                action: .edited,
                itemType: .task,
                itemName: "Fix Leaking Bathroom Faucet"
            ),
            HistoryEntry(
                timestamp: fiveDaysAgo,
                action: .created,
                itemType: .task,
                itemName: "Install New Kitchen Cabinets"
            ),
            HistoryEntry(
                timestamp: fiveDaysAgo.addingTimeInterval(-3600),
                action: .created,
                itemType: .task,
                itemName: "Paint Living Room Walls"
            ),
            HistoryEntry(
                timestamp: oneWeekAgo,
                action: .deleted,
                itemType: .task,
                itemName: "Old task that was deleted"
            ),
            HistoryEntry(
                timestamp: oneWeekAgo.addingTimeInterval(-3600),
                action: .photoAdded,
                itemType: .subtask,
                itemName: "Call city inspector",
                photoURL: "sample://photo3"
            ),
            HistoryEntry(
                timestamp: tenDaysAgo,
                action: .created,
                itemType: .project,
                itemName: "Garden Remodel"
            )
        ]
    }

    // MARK: - Data Methods
    func loadSampleData() {
        tasks = LuxHomeModel.sampleTasks
        subtasks = LuxHomeModel.sampleSubtasks
        let seededWorkers = LuxHomeModel.sampleWorkers
        workers = seededWorkers
        projects = LuxHomeModel.sampleProjects(using: seededWorkers)
        history = LuxHomeModel.sampleHistory
    }

    static var sampleSubtasks: [LuxSubTask] {
        let kitchenCabinetSubtasks = [
            LuxSubTask(name: "Remove old cabinet doors", isCompleted: false, taskId: sampleTaskId1),
            LuxSubTask(name: "Disconnect plumbing and electrical", isCompleted: false, taskId: sampleTaskId1),
            LuxSubTask(name: "Remove old cabinet boxes", isCompleted: false, taskId: sampleTaskId1),
            LuxSubTask(name: "Patch and paint walls", isCompleted: false, taskId: sampleTaskId1),
            LuxSubTask(name: "Install new cabinet boxes", isCompleted: false, taskId: sampleTaskId1),
            LuxSubTask(name: "Level and secure cabinets", isCompleted: false, taskId: sampleTaskId1),
            LuxSubTask(name: "Install cabinet doors and hardware", isCompleted: false, taskId: sampleTaskId1),
            LuxSubTask(name: "Reconnect plumbing and electrical", isCompleted: false, taskId: sampleTaskId1)
        ]

        let paintingSubtasks = [
            LuxSubTask(name: "Move furniture to center", isCompleted: true, taskId: sampleTaskId2, photoURL: "sample://photo1"),
            LuxSubTask(name: "Tape edges and trim", isCompleted: true, taskId: sampleTaskId2),
            LuxSubTask(name: "Apply primer coat", isCompleted: true, taskId: sampleTaskId2, photoURL: "sample://photo2"),
            LuxSubTask(name: "Apply first paint coat", isCompleted: false, taskId: sampleTaskId2),
            LuxSubTask(name: "Apply second paint coat", isCompleted: false, taskId: sampleTaskId2),
            LuxSubTask(name: "Clean up and move furniture back", isCompleted: false, taskId: sampleTaskId2)
        ]

        let faucetSubtasks = [
            LuxSubTask(name: "Turn off water supply", isCompleted: true, taskId: sampleTaskId3),
            LuxSubTask(name: "Disassemble faucet", isCompleted: false, taskId: sampleTaskId3),
            LuxSubTask(name: "Replace washer and O-rings", isCompleted: false, taskId: sampleTaskId3),
            LuxSubTask(name: "Reassemble and test for leaks", isCompleted: false, taskId: sampleTaskId3)
        ]

        let inspectionSubtasks = [
            LuxSubTask(name: "Call city inspector", isCompleted: true, taskId: sampleTaskId4, photoURL: "sample://photo3"),
            LuxSubTask(name: "Schedule appointment", isCompleted: true, taskId: sampleTaskId4),
            LuxSubTask(name: "Prepare documentation", isCompleted: true, taskId: sampleTaskId4, photoURL: "sample://photo4")
        ]

        let singleSubtasks = [
            LuxSubTask(name: "Get Roof Inspection", isCompleted: false, taskId: sampleTaskId5),
            LuxSubTask(name: "Install New Light Fixtures", isCompleted: false, taskId: sampleTaskId6),
            LuxSubTask(name: "Order New Appliances", isCompleted: false, taskId: sampleTaskId7),
            LuxSubTask(name: "Plan Landscaping Project", isCompleted: false, taskId: sampleTaskId8)
        ]

        return kitchenCabinetSubtasks + paintingSubtasks + faucetSubtasks + inspectionSubtasks + singleSubtasks
    }

    private func logHistory(action: HistoryAction, itemType: HistoryItemType, itemName: String, photoURL: String? = nil) {
        let entry = HistoryEntry(
            action: action,
            itemType: itemType,
            itemName: itemName,
            photoURL: photoURL
        )
        history.insert(entry, at: 0)
    }

    // MARK: - Task Management
    func toggleTaskCompletion(_ taskId: UUID) {
        if let index = tasks.firstIndex(where: { $0.id == taskId }) {
            tasks[index].isCompleted.toggle()
            if tasks[index].isCompleted {
                tasks[index].lastCompletedDate = Date()
                logHistory(action: .completed, itemType: .task, itemName: tasks[index].name)
            }
        }
    }

    func updateTask(_ task: LuxTask) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            logHistory(action: .edited, itemType: .task, itemName: task.name)
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
            totalSubtasks: finalSubtaskNames.count,
            isRecurring: isRecurring,
            recurringDay: isRecurring ? dueDay : nil
        )

        tasks.append(newTask)
        logHistory(action: .created, itemType: .task, itemName: name)

        for subtaskName in finalSubtaskNames {
            let subtask = LuxSubTask(
                name: subtaskName,
                isCompleted: false,
                taskId: newTask.id
            )
            subtasks.append(subtask)
        }
    }

    func checkAndResetRecurringTasks() {
        let calendar = Calendar.current
        let today = Date()
        let currentWeekday = calendar.component(.weekday, from: today)
        let weekdayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        let todayName = weekdayNames[currentWeekday - 1]

        for index in tasks.indices {
            let task = tasks[index]
            guard task.isRecurring, let recurringDay = task.recurringDay else { continue }

            if recurringDay == todayName && task.isCompleted {
                resetTaskForNewWeek(at: index, taskId: task.id)
            }
        }
    }

    private func resetTaskForNewWeek(at taskIndex: Int, taskId: UUID) {
        tasks[taskIndex].isCompleted = false
        tasks[taskIndex].completedSubtasks = 0
        resetSubtasksForTask(taskId)
    }

    private func resetSubtasksForTask(_ taskId: UUID) {
        for subtaskIndex in subtasks.indices {
            if subtasks[subtaskIndex].taskId == taskId {
                subtasks[subtaskIndex].isCompleted = false
            }
        }
    }

    func deleteTask(_ taskId: UUID) {
        if let task = tasks.first(where: { $0.id == taskId }) {
            logHistory(action: .deleted, itemType: .task, itemName: task.name)
            tasks.removeAll { $0.id == taskId }
        }
    }

    // MARK: - SubTask Management
    func getSubtasks(for taskId: UUID) -> [LuxSubTask] {
        subtasks.filter { $0.taskId == taskId }
    }

    func addSubtask(_ subtask: LuxSubTask) {
        subtasks.append(subtask)
        updateTaskSubtaskCounts(subtask.taskId)
    }

    func createSubtask(taskId: UUID, name: String) {
        let subtask = LuxSubTask(
            id: UUID(),
            name: name,
            isCompleted: false,
            taskId: taskId,
            photoURL: nil
        )
        addSubtask(subtask)
        logHistory(action: .created, itemType: .subtask, itemName: name)
    }

    func updateSubtaskName(_ subtaskId: UUID, name: String) {
        if let index = subtasks.firstIndex(where: { $0.id == subtaskId }) {
            subtasks[index].name = name
            logHistory(action: .edited, itemType: .subtask, itemName: name)
        }
    }

    func toggleSubtaskCompletion(_ subtaskId: UUID) {
        if let index = subtasks.firstIndex(where: { $0.id == subtaskId }) {
            subtasks[index].isCompleted.toggle()

            if subtasks[index].isCompleted {
                logHistory(action: .completed, itemType: .subtask, itemName: subtasks[index].name)
            }

            updateTaskSubtaskCounts(subtasks[index].taskId)
        }
    }

    func deleteSubtask(_ subtaskId: UUID) {
        if let subtask = subtasks.first(where: { $0.id == subtaskId }) {
            let taskId = subtask.taskId
            logHistory(action: .deleted, itemType: .subtask, itemName: subtask.name)
            subtasks.removeAll { $0.id == subtaskId }
            updateTaskSubtaskCounts(taskId)
        }
    }

    func updateSubtaskPhoto(_ subtaskId: UUID, photoURL: String) {
        if let index = subtasks.firstIndex(where: { $0.id == subtaskId }) {
            subtasks[index].photoURL = photoURL
            subtasks[index].isCompleted = true
            logHistory(action: .photoAdded, itemType: .subtask, itemName: subtasks[index].name, photoURL: photoURL)
            updateTaskSubtaskCounts(subtasks[index].taskId)
        }
    }

    private func updateTaskSubtaskCounts(_ taskId: UUID) {
        if let index = tasks.firstIndex(where: { $0.id == taskId }) {
            let wasCompleted = tasks[index].isCompleted
            let taskSubtasks = subtasks.filter { $0.taskId == taskId }
            let completedCount = taskSubtasks.filter { $0.isCompleted }.count

            tasks[index].totalSubtasks = taskSubtasks.count
            tasks[index].completedSubtasks = completedCount

            if taskSubtasks.count > 0 && completedCount == taskSubtasks.count {
                tasks[index].isCompleted = true
                tasks[index].lastCompletedDate = Date()
                if !wasCompleted {
                    logHistory(action: .completed, itemType: .task, itemName: tasks[index].name)
                }
            } else {
                tasks[index].isCompleted = false
            }
        }
    }

    // MARK: - Project Management
    func createProject(name: String, description: String, dueDate: Date, nextStep: String, assignedWorkers: [ProjectWorkerAssignment] = []) {
        let newProject = LuxProject(
            assignedWorkers: assignedWorkers,
            name: name,
            description: description,
            dueDate: dueDate,
            nextStep: nextStep
        )
        projects.append(newProject)
        logHistory(action: .created, itemType: .project, itemName: name)
    }

    func addPhotoToProject(_ projectId: UUID, photoURL: String) {
        if let index = projects.firstIndex(where: { $0.id == projectId }) {
            projects[index].photoURLs.append(photoURL)
            logHistory(action: .photoAdded, itemType: .project, itemName: projects[index].name, photoURL: photoURL)
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
            logHistory(action: .edited, itemType: .project, itemName: projects[index].name)
        }
    }

    func updateProjectNextStep(_ projectId: UUID, nextStep: String) {
        if let index = projects.firstIndex(where: { $0.id == projectId }) {
            projects[index].nextStep = nextStep
            logHistory(action: .edited, itemType: .project, itemName: projects[index].name)
        }
    }

    func updateProjectAssignments(_ projectId: UUID, assignments: [ProjectWorkerAssignment]) {
        if let index = projects.firstIndex(where: { $0.id == projectId }) {
            projects[index].assignedWorkers = assignments
            logHistory(action: .edited, itemType: .project, itemName: projects[index].name)
        }
    }

    func updateProjectStatus(_ projectId: UUID, status: String) {
        if let index = projects.firstIndex(where: { $0.id == projectId }) {
            projects[index].status = status
            logHistory(action: .edited, itemType: .project, itemName: projects[index].name)
        }
    }

    func deleteProject(_ projectId: UUID) {
        if let project = projects.first(where: { $0.id == projectId }) {
            logHistory(action: .deleted, itemType: .project, itemName: project.name)
            projects.removeAll { $0.id == projectId }
        }
    }

    // MARK: - Worker Management
    @discardableResult
    func createWorker(name: String, company: String, phone: String, email: String?, specialization: String, serviceTypes: [String], scheduleType: ScheduleType) -> LuxWorker {
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
        logHistory(action: .created, itemType: .worker, itemName: name)
        return newWorker
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
            workers[index].isScheduled = true
        }
    }

    func toggleVisitCompletion(_ workerId: UUID, visitId: UUID) {
        if let workerIndex = workers.firstIndex(where: { $0.id == workerId }),
           let visitIndex = workers[workerIndex].scheduledVisits.firstIndex(where: { $0.id == visitId }) {
            workers[workerIndex].scheduledVisits[visitIndex].isDone.toggle()
            recalcNextVisit(for: workerId)
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
            logHistory(action: .edited, itemType: .worker, itemName: name)
        }
    }

    func recordWorkerContact(_ workerId: UUID, contactType: String) {
        if let worker = workers.first(where: { $0.id == workerId }) {
            logHistory(action: .contacted, itemType: .worker, itemName: "\(worker.name) (\(contactType))")
        }
    }

    func removeScheduledVisit(_ workerId: UUID, visitId: UUID) {
        if let index = workers.firstIndex(where: { $0.id == workerId }) {
            workers[index].scheduledVisits.removeAll { $0.id == visitId }
            recalcNextVisit(for: workerId)
        }
    }

    private func recalcNextVisit(for workerId: UUID) {
        if let index = workers.firstIndex(where: { $0.id == workerId }) {
            let upcoming = workers[index].scheduledVisits.sorted(by: { $0.date < $1.date })
            workers[index].nextVisit = upcoming.first?.date
            workers[index].isScheduled = !upcoming.isEmpty
        }
    }

    func updateWorkerSchedule(_ workerId: UUID, scheduleType: ScheduleType, isScheduled: Bool = true) {
        if let index = workers.firstIndex(where: { $0.id == workerId }) {
            workers[index].scheduleType = scheduleType
            workers[index].isScheduled = isScheduled
        }
    }

    func deleteWorker(_ workerId: UUID) {
        if let worker = workers.first(where: { $0.id == workerId }) {
            workers.removeAll { $0.id == workerId }
            // Remove from any project assignments
            for idx in projects.indices {
                projects[idx].assignedWorkers.removeAll { $0.workerId == workerId }
            }
            logHistory(action: .deleted, itemType: .worker, itemName: worker.name)
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

}
