//
//  Project.swift
//  LuxHome
//
//  Created by RJ Kigner on 12/21/25.
//

import Foundation

struct LuxProject: Identifiable, Codable {
    let id: UUID
    var name: String
    var status: String
    var description: String
    var dueDate: Date
    var nextStep: String
    var photoURLs: [String]
    var progressLog: [ProgressLogEntry]

    init(
        id: UUID = UUID(),
        name: String,
        status: String = "In Progress",
        description: String,
        dueDate: Date,
        nextStep: String = "",
        photoURLs: [String] = [],
        progressLog: [ProgressLogEntry] = []
    ) {
        self.id = id
        self.name = name
        self.status = status
        self.description = description
        self.dueDate = dueDate
        self.nextStep = nextStep
        self.photoURLs = photoURLs
        self.progressLog = progressLog
    }
}

struct ProgressLogEntry: Identifiable, Codable {
    let id: UUID
    var date: Date
    var text: String
    var photoURL: String?

    init(
        id: UUID = UUID(),
        date: Date,
        text: String,
        photoURL: String? = nil
    ) {
        self.id = id
        self.date = date
        self.text = text
        self.photoURL = photoURL
    }
}
