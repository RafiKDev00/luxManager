//
//  Task.swift
//  LuxHome
//
//  Created by RJ Kigner on 12/21/25.
//

import Foundation

struct LuxTask: Identifiable, Codable {
    let id: UUID
    var name: String
    var status: String
    var description: String
    var lastCompletedDate: Date?
    var isCompleted: Bool
    var completedSubtasks: Int
    var totalSubtasks: Int

    init(
        id: UUID = UUID(),
        name: String,
        status: String,
        description: String,
        lastCompletedDate: Date? = nil,
        isCompleted: Bool = false,
        completedSubtasks: Int = 0,
        totalSubtasks: Int = 0
    ) {
        self.id = id
        self.name = name
        self.status = status
        self.description = description
        self.lastCompletedDate = lastCompletedDate
        self.isCompleted = isCompleted
        self.completedSubtasks = completedSubtasks
        self.totalSubtasks = totalSubtasks
    }
}

struct LuxSubTask: Identifiable, Codable {
    let id: UUID
    var name: String
    var isCompleted: Bool
    var taskId: UUID // Parent task reference
    var photoURL: String? // Optional photo URL

    init(
        id: UUID = UUID(),
        name: String,
        isCompleted: Bool = false,
        taskId: UUID,
        photoURL: String? = nil
    ) {
        self.id = id
        self.name = name
        self.isCompleted = isCompleted
        self.taskId = taskId
        self.photoURL = photoURL
    }
}
