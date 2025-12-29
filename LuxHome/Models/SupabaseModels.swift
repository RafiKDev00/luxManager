//
//  SupabaseModels.swift
//  LuxHome
//
//  Database models that match the Supabase schema
//  These are Codable versions for network serialization
//

import Foundation

// MARK: - Database Task Model
struct DBTask: Codable, Identifiable {
    let id: UUID
    var name: String
    var status: String
    var description: String?
    var lastCompletedDate: Date?
    var isCompleted: Bool
    var completedSubtasks: Int
    var totalSubtasks: Int
    var isRecurring: Bool
    var recurringInterval: Int?
    var recurringUnit: String?
    let createdAt: Date?
    let updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case status
        case description
        case lastCompletedDate = "last_completed_date"
        case isCompleted = "is_completed"
        case completedSubtasks = "completed_subtasks"
        case totalSubtasks = "total_subtasks"
        case isRecurring = "is_recurring"
        case recurringInterval = "recurring_interval"
        case recurringUnit = "recurring_unit"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Database Subtask Model
struct DBSubtask: Codable, Identifiable {
    let id: UUID
    var taskId: UUID
    var name: String
    var isCompleted: Bool
    var photoUrls: [String]
    let createdAt: Date?
    let updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case taskId = "task_id"
        case name
        case isCompleted = "is_completed"
        case photoUrls = "photo_urls"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Database Project Model
struct DBProject: Codable, Identifiable {
    let id: UUID
    var name: String
    var status: String
    var description: String?
    var dueDate: Date?
    var nextStep: String?
    var photoUrls: [String]
    let createdAt: Date?
    let updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case status
        case description
        case dueDate = "due_date"
        case nextStep = "next_step"
        case photoUrls = "photo_urls"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Database Worker Model
struct DBWorker: Codable, Identifiable {
    let id: UUID
    var name: String
    var company: String
    var phone: String
    var email: String?
    var specialization: String
    var serviceTypes: [String]
    var scheduleType: String
    var isScheduled: Bool
    var nextVisit: Date?
    var photoUrl: String?
    let createdAt: Date?
    let updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case company
        case phone
        case email
        case specialization
        case serviceTypes = "service_types"
        case scheduleType = "schedule_type"
        case isScheduled = "is_scheduled"
        case nextVisit = "next_visit"
        case photoUrl = "photo_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Database Project Worker Assignment
struct DBProjectWorker: Codable, Identifiable {
    let id: UUID
    var projectId: UUID
    var workerId: UUID
    var role: String?
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case projectId = "project_id"
        case workerId = "worker_id"
        case role
        case createdAt = "created_at"
    }
}

// MARK: - Database Progress Log Entry
struct DBProgressLogEntry: Codable, Identifiable {
    let id: UUID
    var projectId: UUID
    var date: Date
    var text: String
    var photoUrls: [String]
    let createdAt: Date?
    let updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case projectId = "project_id"
        case date
        case text
        case photoUrls = "photo_urls"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Database Scheduled Visit
struct DBScheduledVisit: Codable, Identifiable {
    let id: UUID
    var workerId: UUID
    var projectId: UUID?
    var date: Date
    var notes: String?
    var isDone: Bool
    let createdAt: Date?
    let updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case workerId = "worker_id"
        case projectId = "project_id"
        case date
        case notes
        case isDone = "is_done"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Database Checklist Item
struct DBChecklistItem: Codable, Identifiable {
    let id: UUID
    var visitId: UUID
    var title: String
    var isCompleted: Bool
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case visitId = "visit_id"
        case title
        case isCompleted = "is_completed"
        case createdAt = "created_at"
    }
}

// MARK: - Database History Entry
struct DBHistoryEntry: Codable, Identifiable {
    let id: UUID
    var timestamp: Date
    var action: String
    var itemType: String
    var itemName: String
    var photoUrl: String?
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case timestamp
        case action
        case itemType = "item_type"
        case itemName = "item_name"
        case photoUrl = "photo_url"
        case createdAt = "created_at"
    }
}

// MARK: - Conversion Extensions

extension LuxTask {
    func toDBTask() -> DBTask {
        DBTask(
            id: id,
            name: name,
            status: status,
            description: description,
            lastCompletedDate: lastCompletedDate,
            isCompleted: isCompleted,
            completedSubtasks: completedSubtasks,
            totalSubtasks: totalSubtasks,
            isRecurring: isRecurring,
            recurringInterval: recurringInterval,
            recurringUnit: recurringUnit?.rawValue,
            createdAt: nil,
            updatedAt: nil
        )
    }

    init(from dbTask: DBTask) {
        self.init(
            id: dbTask.id,
            name: dbTask.name,
            status: dbTask.status,
            description: dbTask.description ?? "",
            lastCompletedDate: dbTask.lastCompletedDate,
            isCompleted: dbTask.isCompleted,
            completedSubtasks: dbTask.completedSubtasks,
            totalSubtasks: dbTask.totalSubtasks,
            isRecurring: dbTask.isRecurring,
            recurringInterval: dbTask.recurringInterval,
            recurringUnit: dbTask.recurringUnit.flatMap { RecurringInterval(rawValue: $0) }
        )
    }
}

extension LuxSubTask {
    func toDBSubtask() -> DBSubtask {
        DBSubtask(
            id: id,
            taskId: taskId,
            name: name,
            isCompleted: isCompleted,
            photoUrls: photoURLs,
            createdAt: nil,
            updatedAt: nil
        )
    }

    init(from dbSubtask: DBSubtask) {
        self.init(
            id: dbSubtask.id,
            name: dbSubtask.name,
            isCompleted: dbSubtask.isCompleted,
            taskId: dbSubtask.taskId,
            photoURLs: dbSubtask.photoUrls
        )
    }
}

extension LuxProject {
    func toDBProject() -> DBProject {
        DBProject(
            id: id,
            name: name,
            status: status,
            description: description,
            dueDate: dueDate,
            nextStep: nextStep,
            photoUrls: photoURLs,
            createdAt: nil,
            updatedAt: nil
        )
    }

    init(from dbProject: DBProject, workers: [ProjectWorkerAssignment], progressLog: [ProgressLogEntry]) {
        self.init(
            id: dbProject.id,
            assignedWorkers: workers,
            name: dbProject.name,
            status: dbProject.status,
            description: dbProject.description ?? "",
            dueDate: dbProject.dueDate ?? Date(),
            nextStep: dbProject.nextStep ?? "",
            photoURLs: dbProject.photoUrls,
            progressLog: progressLog
        )
    }
}

extension LuxWorker {
    func toDBWorker() -> DBWorker {
        DBWorker(
            id: id,
            name: name,
            company: company,
            phone: phone,
            email: email,
            specialization: specialization,
            serviceTypes: serviceTypes,
            scheduleType: scheduleType.rawValue,
            isScheduled: isScheduled,
            nextVisit: nextVisit,
            photoUrl: photoURL,
            createdAt: nil,
            updatedAt: nil
        )
    }

    init(from dbWorker: DBWorker, visits: [ScheduledVisit]) {
        self.init(
            id: dbWorker.id,
            name: dbWorker.name,
            company: dbWorker.company,
            phone: dbWorker.phone,
            email: dbWorker.email,
            specialization: dbWorker.specialization,
            serviceTypes: dbWorker.serviceTypes,
            scheduleType: ScheduleType(rawValue: dbWorker.scheduleType) ?? .oneTime,
            isScheduled: dbWorker.isScheduled,
            nextVisit: dbWorker.nextVisit,
            scheduledVisits: visits,
            photoURL: dbWorker.photoUrl
        )
    }
}

extension ProgressLogEntry {
    func toDBProgressLogEntry(projectId: UUID) -> DBProgressLogEntry {
        DBProgressLogEntry(
            id: id,
            projectId: projectId,
            date: date,
            text: text,
            photoUrls: photoURLs,
            createdAt: nil,
            updatedAt: nil
        )
    }

    init(from dbEntry: DBProgressLogEntry) {
        self.init(
            id: dbEntry.id,
            date: dbEntry.date,
            text: dbEntry.text,
            photoURLs: dbEntry.photoUrls
        )
    }
}

extension ScheduledVisit {
    func toDBScheduledVisit(workerId: UUID) -> DBScheduledVisit {
        DBScheduledVisit(
            id: id,
            workerId: workerId,
            projectId: projectId,
            date: date,
            notes: notes,
            isDone: isDone,
            createdAt: nil,
            updatedAt: nil
        )
    }

    init(from dbVisit: DBScheduledVisit, checklist: [ChecklistItem]) {
        self.init(
            id: dbVisit.id,
            date: dbVisit.date,
            notes: dbVisit.notes ?? "",
            checklist: checklist,
            isDone: dbVisit.isDone,
            projectId: dbVisit.projectId
        )
    }
}

extension HistoryEntry {
    func toDBHistoryEntry() -> DBHistoryEntry {
        DBHistoryEntry(
            id: id,
            timestamp: timestamp,
            action: action.rawValue,
            itemType: itemType.rawValue,
            itemName: itemName,
            photoUrl: photoURL,
            createdAt: nil
        )
    }

    init(from dbEntry: DBHistoryEntry) {
        self.init(
            id: dbEntry.id,
            timestamp: dbEntry.timestamp,
            action: HistoryAction(rawValue: dbEntry.action) ?? .created,
            itemType: HistoryItemType(rawValue: dbEntry.itemType) ?? .task,
            itemName: dbEntry.itemName,
            photoURL: dbEntry.photoUrl
        )
    }
}
