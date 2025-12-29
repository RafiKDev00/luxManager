# Supabase Integration - Completion Guide

## What's Done ✅

1. **Development mode flag** - `isDevelopmentMode = false` (set to true for sample data)
2. **Fetch methods** - All data loads from Supabase on app start
3. **Error handling** - Centralized error handling with typed errors
4. **History logging** - Automatically saves to Supabase
5. **Supabase CRUD extension** - `/Models/LuxHomeModel+Supabase.swift` with all save methods
6. **toggleTaskCompletion** - Updated to save to Supabase

## What Needs Updating

Add the Supabase save call to these methods in `LuxHomeModel.swift`. Pattern to follow:

```swift
// After local update:
if !isDevelopmentMode {
    Task {
        do {
            try await saveXXX(item)  // or createXXXInSupabase / deleteXXXFromSupabase
        } catch {
            handleError(error)
        }
    }
}
```

### Task Methods (Lines ~689-785)
- [ ] `updateTask(_ task:)` - Add `saveTask(task)`
- [ ] `updateTaskName(_ taskId:, name:)` - Add `saveTask(tasks[index])`
- [ ] `createTask(...)` - Add `createTaskInSupabase(newTask)` and `createSubtaskInSupabase` for each subtask
- [ ] `deleteTask(_ taskId:)` - Add `deleteTaskFromSupabase(taskId)`

### Subtask Methods (Lines ~787-854)
- [ ] `updateSubtaskName(_ subtaskId:, name:)` - Add `saveSubtask(subtasks[index])`
- [ ] `toggleSubtaskCompletion(_ subtaskId:)` - Add `saveSubtask(subtasks[index])`
- [ ] `deleteSubtask(_ subtaskId:)` - Add `deleteSubtaskFromSupabase(subtaskId)`
- [ ] `addPhotoToSubtask(_ subtaskId:, photoURL:)` - First `uploadPhoto(imageData)` then `saveSubtask`
- [ ] `deletePhotoFromSubtask(_ subtaskId:, photoURL:)` - Add `deletePhoto(url:)` then `saveSubtask`
- [ ] `createSubtask(taskId:, name:)` - Add `createSubtaskInSupabase(subtask)`

### Project Methods (Lines ~856-979)
- [ ] `createProject(...)` - Add `createProjectInSupabase(newProject)`
- [ ] `addPhotoToProject(_ projectId:, photoURL:)` - First `uploadPhoto` then `saveProject`
- [ ] `removePhotoFromProject(_ projectId:, photoURL:)` - Add `deletePhoto` then `saveProject`
- [ ] `addProgressLogEntry(to projectId:, ...)` - Add `createProgressLogEntryInSupabase`
- [ ] `addPhotoToProgressLogEntry(to projectId:, entryId:, photoURL:)` - Upload photo then `saveProgressLogEntry`
- [ ] `deletePhotoFromProgressLogEntry(projectId:, entryId:, photoURL:)` - Delete photo then `saveProgressLogEntry`
- [ ] `updateProgressLogEntry(to projectId:, entryId:, text:)` - Add `saveProgressLogEntry`
- [ ] `deleteProgressLogEntry(from projectId:, entryId:)` - Add `deleteProgressLogEntryFromSupabase`
- [ ] `updateProjectNextStep(_ projectId:, nextStep:)` - Add `saveProject`
- [ ] `updateProjectAssignments(_ projectId:, assignments:)` - Add `saveProject`
- [ ] `updateProjectStatus(_ projectId:, status:)` - Add `saveProject`
- [ ] `updateProjectDetails(_ projectId:, ...)` - Add `saveProject`
- [ ] `deleteProject(_ projectId:)` - Add `deleteProjectFromSupabase`

### Worker Methods (Lines ~980-1027)
- [ ] `createWorker(...)` - Add `createWorkerInSupabase(newWorker)`
- [ ] `toggleWorkerSchedule(_ workerId:, isScheduled:)` - Add `saveWorker`
- [ ] `addScheduledVisit(to workerId:, visit:)` - Add `createScheduledVisitInSupabase`
- [ ] `toggleVisitCompletion(_ workerId:, visitId:)` - Add `saveScheduledVisit`
- [ ] `updateWorker(_ workerId:, ...)` - Add `saveWorker`
- [ ] `removeScheduledVisit(_ workerId:, visitId:)` - Add `deleteScheduledVisitFromSupabase`
- [ ] `updateWorkerSchedule(_ workerId:, scheduleType:, isScheduled:)` - Add `saveWorker`
- [ ] `deleteWorker(_ workerId:)` - Add `deleteWorkerFromSupabase`

## Files to Add to Xcode

Make sure these are in your Xcode project:
- `/LuxHome/Services/SupabaseService.swift`
- `/LuxHome/Models/SupabaseModels.swift`
- `/LuxHome/Models/LuxHomeModel+Supabase.swift` (NEW - just created)

## How Photo Upload Works

When user selects a photo:
1. Get the `Data` from PhotosPicker
2. Call `uploadPhoto(imageData)` - returns Supabase public URL
3. Save that URL string to the model (subtask.photoURLs, project.photoURLs, etc)
4. Save the model to Supabase

When deleting a photo:
1. Call `deletePhoto(url: photoURL)`
2. Remove from local array
3. Save the model to Supabase

## Testing Checklist

Once all methods are updated:

1. **Build** (Cmd+B) - Should compile without errors
2. **Run with dev mode ON** (`isDevelopmentMode = true`)
   - Should see sample data
   - Changes don't save (like before)
3. **Run with dev mode OFF** (`isDevelopmentMode = false`)
   - Should start empty
   - Create a task → Check Supabase Table Editor, should see it
   - Edit the task → Refresh table, should update
   - Delete the task → Refresh table, should be gone
4. **Test photos**
   - Add photo to subtask → Check Storage bucket, file should exist
   - Check subtask in database → `photo_urls` should have Supabase URL
   - Delete photo → Check Storage bucket, file should be gone

## Quick Win: Seed Sample Data to Supabase

Want to test with data? Add this method to test:

```swift
func seedSampleDataToSupabase() async {
    for task in LuxHomeModel.sampleTasks {
        try? await createTaskInSupabase(task)
    }
    for subtask in LuxHomeModel.sampleSubtasks {
        try? await createSubtaskInSupabase(subtask)
    }
    // etc...
}
```

Call it once, then you'll have sample data in Supabase!

## Current Status

- ✅ Architecture complete (Booster pattern followed)
- ✅ All fetch methods working
- ✅ All save methods created
- ⏳ Need to wire up save calls in existing CRUD methods (~40 methods)
- ⏳ Photo upload integration

Estimated: 30-45 min to add all the save calls following the pattern above.
