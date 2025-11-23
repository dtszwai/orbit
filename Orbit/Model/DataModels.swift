import Foundation
import SwiftData

// MARK: - SwiftData Models

@Model
class TaskItem {
    var id: UUID
    var title: String
    var durationMinutes: Int
    var isCompleted: Bool
    var createdAt: Date
    
    init(title: String, durationMinutes: Int) {
        self.id = UUID()
        self.title = title
        self.durationMinutes = durationMinutes
        self.isCompleted = false
        self.createdAt = Date()
    }
}

@Model
class FocusSession {
    var id: UUID
    var startTime: Date
    var durationSeconds: Int
    var taskTitle: String?
    
    init(durationSeconds: Int, taskTitle: String? = nil) {
        self.id = UUID()
        self.startTime = Date()
        self.durationSeconds = durationSeconds
        self.taskTitle = taskTitle
    }
}