//
//  Task.swift
//  LuxHome
//
//  Created by RJ Kigner on 12/21/25.
//

import Foundation

enum RecurringInterval: String, Codable, CaseIterable {
    case weeks = "Weeks"
    case months = "Months"
}

struct LuxTask: Identifiable, Codable {
    let id: UUID
    var name: String
    var status: String
    var description: String
    var lastCompletedDate: Date?
    var isCompleted: Bool
    var completedSubtasks: Int
    var totalSubtasks: Int
    let createdAt: Date
    var isRecurring: Bool
    var recurringInterval: Int? // e.g., 2 (for "every 2 weeks")
    var recurringUnit: RecurringInterval? // .weeks or .months

    init(
        id: UUID = UUID(),
        name: String,
        status: String,
        description: String,
        lastCompletedDate: Date? = nil,
        isCompleted: Bool = false,
        completedSubtasks: Int = 0,
        totalSubtasks: Int = 0,
        createdAt: Date = Date(),
        isRecurring: Bool = false,
        recurringInterval: Int? = nil,
        recurringUnit: RecurringInterval? = nil
    ) {
        self.id = id
        self.name = name
        self.status = status
        self.description = description
        self.lastCompletedDate = lastCompletedDate
        self.isCompleted = isCompleted
        self.completedSubtasks = completedSubtasks
        self.totalSubtasks = totalSubtasks
        self.createdAt = createdAt
        self.isRecurring = isRecurring
        self.recurringInterval = recurringInterval
        self.recurringUnit = recurringUnit
    }

    // Helper computed property for display
    var recurringDescription: String {
        guard isRecurring, let interval = recurringInterval, let unit = recurringUnit else {
            return "One-time"
        }
        if interval == 1 {
            return "Every \(unit.rawValue.dropLast())" // "Every Week" or "Every Month"
        } else {
            return "Every \(interval) \(unit.rawValue)"
        }
    }

    // Calculate the next due date based on last completion
    var nextDueDate: Date? {
        guard isRecurring, let interval = recurringInterval, let unit = recurringUnit else {
            return nil
        }

        let calendar = Calendar.current
        let baseDate = lastCompletedDate ?? createdAt

        switch unit {
        case .weeks:
            return calendar.date(byAdding: .weekOfYear, value: interval, to: baseDate)
        case .months:
            return calendar.date(byAdding: .month, value: interval, to: baseDate)
        }
    }

    // Helper to get relative due date string
    func dueDateDescription(from date: Date = Date()) -> String {
        guard let dueDate = nextDueDate else { return "" }

        let calendar = Calendar.current
        let now = calendar.startOfDay(for: date)
        let due = calendar.startOfDay(for: dueDate)

        let days = calendar.dateComponents([.day], from: now, to: due).day ?? 0

        if days <= 0 {
            return "Due today"
        } else if days == 1 {
            return "Due tomorrow"
        } else if days <= 7 {
            return "Due in \(days) days"
        } else if days <= 30 {
            let weeks = days / 7
            if weeks == 1 {
                return "Due in 1 week"
            } else {
                return "Due in \(weeks) weeks"
            }
        } else {
            let months = days / 30
            if months == 1 {
                return "Due in 1 month"
            } else {
                return "Due in \(months) months"
            }
        }
    }
}

struct LuxSubTask: Identifiable, Codable {
    let id: UUID
    var name: String
    var isCompleted: Bool
    var taskId: UUID // Parent task reference
    var photoURLs: [String] // Multiple photo URLs

    init(
        id: UUID = UUID(),
        name: String,
        isCompleted: Bool = false,
        taskId: UUID,
        photoURLs: [String] = []
    ) {
        self.id = id
        self.name = name
        self.isCompleted = isCompleted
        self.taskId = taskId
        self.photoURLs = photoURLs
    }
}
