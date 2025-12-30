//
//  Project.swift
//  LuxHome
//
//  Created by RJ Kigner on 12/21/25.
//

import Foundation

struct LuxProject: Identifiable, Codable {
    let id: UUID
    var assignedWorkers: [ProjectWorkerAssignment]
    var name: String
    var status: String
    var description: String

    // ⚠️ TODO: REMOVE DUE DATE - This field is unused but still exists in database
    // Currently set to year 2125 as a placeholder. Should be removed from:
    // - This model
    // - Database schema (run ALTER TABLE projects DROP COLUMN due_date)
    // - DBProject in SupabaseModels.swift
    // - All createProject/updateProject functions
    var dueDate: Date

    var nextStep: String
    var photoURLs: [String]
    var progressLog: [ProgressLogEntry]

    init(
        id: UUID = UUID(),
        assignedWorkers: [ProjectWorkerAssignment] = [],
        name: String,
        status: String = "In Progress",
        description: String,
        dueDate: Date,
        nextStep: String = "",
        photoURLs: [String] = [],
        progressLog: [ProgressLogEntry] = []
    ) {
        self.id = id
        self.assignedWorkers = assignedWorkers
        self.name = name
        self.status = status
        self.description = description
        self.dueDate = dueDate
        self.nextStep = nextStep
        self.photoURLs = photoURLs
        self.progressLog = progressLog
    }
}

struct ProjectWorkerAssignment: Identifiable, Codable, Equatable {
    let id: UUID
    var workerId: UUID
    var role: String

    init(id: UUID = UUID(), workerId: UUID, role: String = "") {
        self.id = id
        self.workerId = workerId
        self.role = role
    }
}

struct ProgressLogEntry: Identifiable, Codable {
    let id: UUID
    var date: Date
    var text: String
    var photoURLs: [String]

    init(
        id: UUID = UUID(),
        date: Date,
        text: String,
        photoURLs: [String] = []
    ) {
        self.id = id
        self.date = date
        self.text = text
        self.photoURLs = photoURLs
    }
}
