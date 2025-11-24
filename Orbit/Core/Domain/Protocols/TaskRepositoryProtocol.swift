import Foundation

// MARK: - Task Repository Protocol
/// Protocol defining the interface for task data access
protocol TaskRepositoryProtocol {
    /// Fetch all tasks
    func fetchAll() -> [TaskItem]

    /// Save a new task
    func save(_ task: TaskItem) throws

    /// Delete a task
    func delete(_ task: TaskItem) throws

    /// Update task completion status
    func toggleCompletion(_ task: TaskItem) throws

    /// Delete all completed tasks
    func deleteCompleted() throws
}
