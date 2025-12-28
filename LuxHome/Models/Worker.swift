//
//  Worker.swift
//  LuxHome
//
//  Created by RJ Kigner on 12/21/25.
//

import Foundation

struct LuxWorker: Identifiable, Codable {
    let id: UUID
    var name: String
    var company: String
    var phone: String
    var email: String?
    var specialization: String
    var serviceTypes: [String]
    var scheduleType: ScheduleType
    var isScheduled: Bool
    var nextVisit: Date?
    var scheduledVisits: [ScheduledVisit]
    var photoURL: String?

    init(
        id: UUID = UUID(),
        name: String,
        company: String,
        phone: String,
        email: String? = nil,
        specialization: String,
        serviceTypes: [String] = [],
        scheduleType: ScheduleType = .oneTime,
        isScheduled: Bool = false,
        nextVisit: Date? = nil,
        scheduledVisits: [ScheduledVisit] = [],
        photoURL: String? = nil
    ) {
        self.id = id
        self.name = name
        self.company = company
        self.phone = phone
        self.email = email
        self.specialization = specialization
        self.serviceTypes = serviceTypes
        self.scheduleType = scheduleType
        self.isScheduled = isScheduled
        self.nextVisit = nextVisit
        self.scheduledVisits = scheduledVisits
        self.photoURL = photoURL
    }
}

enum ScheduleType: String, Codable, CaseIterable {
    case oneTime = "One-Time"
    case weekly = "Weekly"
    case biWeekly = "Bi-Weekly"
    case monthly = "Monthly"
}

struct ScheduledVisit: Identifiable, Codable {
    let id: UUID
    var date: Date
    var notes: String
    var checklist: [ChecklistItem]
    var isDone: Bool
    var projectId: UUID?

    init(
        id: UUID = UUID(),
        date: Date,
        notes: String = "",
        checklist: [ChecklistItem] = [],
        isDone: Bool = false,
        projectId: UUID? = nil
    ) {
        self.id = id
        self.date = date
        self.notes = notes
        self.checklist = checklist
        self.isDone = isDone
        self.projectId = projectId
    }
}

struct ChecklistItem: Identifiable, Codable {
    let id: UUID
    var title: String
    var isCompleted: Bool

    init(
        id: UUID = UUID(),
        title: String,
        isCompleted: Bool = false
    ) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
    }
}
