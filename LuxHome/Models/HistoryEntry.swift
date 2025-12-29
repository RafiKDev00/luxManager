//
//  HistoryEntry.swift
//  LuxHome
//
//  Created by RJ Kigner on 12/23/25.
//

import Foundation

enum HistoryAction: String, Codable {
    case created = "Created"
    case completed = "Completed"
    case edited = "Edited"
    case deleted = "Deleted"
    case photoAdded = "Photo Added"
    case photoDeleted = "Photo Deleted"
    case contacted = "Contacted"
}

enum HistoryItemType: String, Codable {
    case task = "Task"
    case project = "Project"
    case worker = "Worker"
    case subtask = "Subtask"
}

struct HistoryEntry: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let action: HistoryAction
    let itemType: HistoryItemType
    let itemName: String
    let photoURL: String?

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        action: HistoryAction,
        itemType: HistoryItemType,
        itemName: String,
        photoURL: String? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.action = action
        self.itemType = itemType
        self.itemName = itemName
        self.photoURL = photoURL
    }

    var displayText: String {
        "\(action.rawValue) \(itemType.rawValue): \(itemName)"
    }
}
