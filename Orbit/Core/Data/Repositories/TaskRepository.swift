import Foundation
import SwiftData

// MARK: - Task Repository
/// Repository for managing TaskItem data persistence
final class TaskRepository: TaskRepositoryProtocol {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchAll() -> [TaskItem] {
        let descriptor = FetchDescriptor<TaskItem>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    func save(_ task: TaskItem) throws {
        context.insert(task)
        try context.save()
    }

    func delete(_ task: TaskItem) throws {
        context.delete(task)
        try context.save()
    }

    func toggleCompletion(_ task: TaskItem) throws {
        task.isCompleted.toggle()
        try context.save()
    }

    func deleteCompleted() throws {
        let descriptor = FetchDescriptor<TaskItem>(
            predicate: #Predicate { $0.isCompleted }
        )
        let completedTasks = (try? context.fetch(descriptor)) ?? []

        for task in completedTasks {
            context.delete(task)
        }

        try context.save()
    }
}
