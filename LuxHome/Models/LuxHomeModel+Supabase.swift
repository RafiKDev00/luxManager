//
//  LuxHomeModel+Supabase.swift
//  LuxHome
//
//  Created by RJ Kigner on 12/21/25.
//
//  Supabase integration for all CRUD operations
//  Following Booster pattern: centralized networking in model layer
//

import Foundation

extension LuxHomeModel {
    // MARK: - Task CRUD

    @MainActor
    func saveTask(_ task: LuxTask) async throws {
        let dbTask = task.toDBTask()
        let saved: [DBTask] = try await SupabaseService.shared.patch(
            endpoint: "/tasks?id=eq.\(task.id.uuidString)",
            body: dbTask
        )
        if let updatedTask = saved.first {
            if let index = tasks.firstIndex(where: { $0.id == task.id }) {
                tasks[index] = LuxTask(from: updatedTask)
            }
        }
    }

    @MainActor
    func createTaskInSupabase(_ task: LuxTask) async throws {
        let dbTask = task.toDBTask()
        let _: [DBTask] = try await SupabaseService.shared.post(
            endpoint: "/tasks",
            body: dbTask
        )
        print("✅ Created task in Supabase: \(task.name)")
    }

    @MainActor
    func deleteTaskFromSupabase(_ taskId: UUID) async throws {
        try await SupabaseService.shared.delete(endpoint: "/tasks?id=eq.\(taskId.uuidString)")
        tasks.removeAll { $0.id == taskId }
    }

    // MARK: - Subtask CRUD

    @MainActor
    func saveSubtask(_ subtask: LuxSubTask) async throws {
        let dbSubtask = subtask.toDBSubtask()
        let saved: [DBSubtask] = try await SupabaseService.shared.patch(
            endpoint: "/subtasks?id=eq.\(subtask.id.uuidString)",
            body: dbSubtask
        )
        if let updatedSubtask = saved.first {
            if let index = subtasks.firstIndex(where: { $0.id == subtask.id }) {
                subtasks[index] = LuxSubTask(from: updatedSubtask)
            }
        }
    }

    @MainActor
    func createSubtaskInSupabase(_ subtask: LuxSubTask) async throws {
        let dbSubtask = subtask.toDBSubtask()
        let _: [DBSubtask] = try await SupabaseService.shared.post(
            endpoint: "/subtasks",
            body: dbSubtask
        )
        print("✅ Created subtask in Supabase: \(subtask.name)")
    }

    @MainActor
    func deleteSubtaskFromSupabase(_ subtaskId: UUID) async throws {
        try await SupabaseService.shared.delete(endpoint: "/subtasks?id=eq.\(subtaskId.uuidString)")
        subtasks.removeAll { $0.id == subtaskId }
    }

    // MARK: - Project CRUD

    @MainActor
    func saveProject(_ project: LuxProject) async throws {
        let dbProject = project.toDBProject()
        let saved: [DBProject] = try await SupabaseService.shared.patch(
            endpoint: "/projects?id=eq.\(project.id.uuidString)",
            body: dbProject
        )

        // Update project_workers assignments
        // First delete existing assignments
        try await SupabaseService.shared.delete(endpoint: "/project_workers?project_id=eq.\(project.id.uuidString)")

        // Then create new assignments
        for assignment in project.assignedWorkers {
            let dbAssignment = DBProjectWorker(
                id: UUID(),
                projectId: project.id,
                workerId: assignment.workerId,
                role: assignment.role,
                createdAt: nil
            )
            let _: [DBProjectWorker] = try await SupabaseService.shared.post(
                endpoint: "/project_workers",
                body: dbAssignment
            )
        }

        if let updatedProject = saved.first {
            if let index = projects.firstIndex(where: { $0.id == project.id }) {
                projects[index] = LuxProject(
                    from: updatedProject,
                    workers: project.assignedWorkers,
                    progressLog: project.progressLog
                )
            }
        }
    }

    @MainActor
    func createProjectInSupabase(_ project: LuxProject) async throws {
        let dbProject = project.toDBProject()
        let _: [DBProject] = try await SupabaseService.shared.post(
            endpoint: "/projects",
            body: dbProject
        )

        // Create worker assignments
        for assignment in project.assignedWorkers {
            let dbAssignment = DBProjectWorker(
                id: UUID(),
                projectId: project.id,
                workerId: assignment.workerId,
                role: assignment.role,
                createdAt: nil
            )
            let _: [DBProjectWorker] = try await SupabaseService.shared.post(
                endpoint: "/project_workers",
                body: dbAssignment
            )
        }

        print("✅ Created project in Supabase: \(project.name)")
    }

    @MainActor
    func deleteProjectFromSupabase(_ projectId: UUID) async throws {
        try await SupabaseService.shared.delete(endpoint: "/projects?id=eq.\(projectId.uuidString)")
        projects.removeAll { $0.id == projectId }
    }

    // MARK: - Progress Log CRUD

    @MainActor
    func saveProgressLogEntry(_ entry: ProgressLogEntry, projectId: UUID) async throws {
        let dbEntry = entry.toDBProgressLogEntry(projectId: projectId)
        let saved: [DBProgressLogEntry] = try await SupabaseService.shared.patch(
            endpoint: "/progress_log_entries?id=eq.\(entry.id.uuidString)",
            body: dbEntry
        )

        if let index = projects.firstIndex(where: { $0.id == projectId }) {
            if let logIndex = projects[index].progressLog.firstIndex(where: { $0.id == entry.id }) {
                if let updated = saved.first {
                    projects[index].progressLog[logIndex] = ProgressLogEntry(from: updated)
                }
            }
        }
    }

    @MainActor
    func createProgressLogEntryInSupabase(_ entry: ProgressLogEntry, projectId: UUID) async throws {
        let dbEntry = entry.toDBProgressLogEntry(projectId: projectId)
        let _: [DBProgressLogEntry] = try await SupabaseService.shared.post(
            endpoint: "/progress_log_entries",
            body: dbEntry
        )
        print("✅ Created progress log entry in Supabase")
    }

    @MainActor
    func deleteProgressLogEntryFromSupabase(_ entryId: UUID, projectId: UUID) async throws {
        try await SupabaseService.shared.delete(endpoint: "/progress_log_entries?id=eq.\(entryId.uuidString)")

        if let index = projects.firstIndex(where: { $0.id == projectId }) {
            projects[index].progressLog.removeAll { $0.id == entryId }
        }
    }

    // MARK: - Worker CRUD

    @MainActor
    func saveWorker(_ worker: LuxWorker) async throws {
        let dbWorker = worker.toDBWorker()
        let saved: [DBWorker] = try await SupabaseService.shared.patch(
            endpoint: "/workers?id=eq.\(worker.id.uuidString)",
            body: dbWorker
        )

        if let updatedWorker = saved.first {
            if let index = workers.firstIndex(where: { $0.id == worker.id }) {
                workers[index] = LuxWorker(from: updatedWorker, visits: worker.scheduledVisits)
            }
        }
    }

    @MainActor
    func createWorkerInSupabase(_ worker: LuxWorker) async throws {
        let dbWorker = worker.toDBWorker()
        let _: [DBWorker] = try await SupabaseService.shared.post(
            endpoint: "/workers",
            body: dbWorker
        )
        print("✅ Created worker in Supabase: \(worker.name)")
    }

    @MainActor
    func deleteWorkerFromSupabase(_ workerId: UUID) async throws {
        try await SupabaseService.shared.delete(endpoint: "/workers?id=eq.\(workerId.uuidString)")
        workers.removeAll { $0.id == workerId }
    }

    // MARK: - Scheduled Visit CRUD

    @MainActor
    func saveScheduledVisit(_ visit: ScheduledVisit, workerId: UUID) async throws {
        let dbVisit = visit.toDBScheduledVisit(workerId: workerId)
        let saved: [DBScheduledVisit] = try await SupabaseService.shared.patch(
            endpoint: "/scheduled_visits?id=eq.\(visit.id.uuidString)",
            body: dbVisit
        )

        if let index = workers.firstIndex(where: { $0.id == workerId }) {
            if let visitIndex = workers[index].scheduledVisits.firstIndex(where: { $0.id == visit.id }) {
                if let updated = saved.first {
                    workers[index].scheduledVisits[visitIndex] = ScheduledVisit(from: updated, checklist: visit.checklist)
                }
            }
        }
    }

    @MainActor
    func createScheduledVisitInSupabase(_ visit: ScheduledVisit, workerId: UUID) async throws {
        let dbVisit = visit.toDBScheduledVisit(workerId: workerId)
        let _: [DBScheduledVisit] = try await SupabaseService.shared.post(
            endpoint: "/scheduled_visits",
            body: dbVisit
        )
        print("✅ Created scheduled visit in Supabase")
    }

    @MainActor
    func deleteScheduledVisitFromSupabase(_ visitId: UUID, workerId: UUID) async throws {
        try await SupabaseService.shared.delete(endpoint: "/scheduled_visits?id=eq.\(visitId.uuidString)")

        if let index = workers.firstIndex(where: { $0.id == workerId }) {
            workers[index].scheduledVisits.removeAll { $0.id == visitId }
            // Recalculate next visit
            let upcoming = workers[index].scheduledVisits.sorted(by: { $0.date < $1.date })
            workers[index].nextVisit = upcoming.first?.date
        }
    }

    // MARK: - Photo Upload

    func uploadPhoto(_ imageData: Data, filename: String) async throws -> String {
        return try await SupabaseService.shared.uploadPhoto(imageData, filename: filename)
    }

    func deletePhoto(url: String) async throws {
        // Only delete from Supabase Storage if it's a Supabase URL
        guard url.starts(with: "http") else {
            print("⚠️ Skipping deletion - not a Supabase URL: \(url)")
            return
        }

        // Extract filename from URL
        if let filename = url.components(separatedBy: "/").last {
            try await SupabaseService.shared.deletePhoto(filename: filename)
        }
    }
}
