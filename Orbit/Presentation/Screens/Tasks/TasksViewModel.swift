import Foundation
import SwiftUI
import SwiftData

@MainActor
final class TasksViewModel: ObservableObject {
    @Published var tasks: [TaskItem] = []
    @Published var newTaskTitle: String = ""
    @Published var newTaskDuration: Int = AppConfiguration.Timer.defaultDurationMinutes
    @Published var isAddingTask: Bool = false
    @Published var isRunning: Bool = false
    @Published var currentTask: TaskItem?

    private let container: DependencyContainer
    let durationOptions = AppConfiguration.Timer.availableDurations

    init(container: DependencyContainer) {
        self.container = container
        bindToServices()
    }

    private func bindToServices() {
        container.timerService.$isRunning
            .assign(to: &$isRunning)
        container.$currentTask
            .assign(to: &$currentTask)
    }

    func loadTasks() {
        tasks = container.taskRepository?.fetchAll() ?? []
    }

    func addTask() {
        guard !newTaskTitle.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        let task = TaskItem(
            title: newTaskTitle.trimmingCharacters(in: .whitespaces),
            durationMinutes: newTaskDuration
        )

        try? container.taskRepository?.save(task)
        resetForm()
        loadTasks()
    }

    func deleteTask(_ task: TaskItem) {
        try? container.taskRepository?.delete(task)
        loadTasks()
    }

    func toggleTaskCompletion(_ task: TaskItem) {
        try? container.taskRepository?.toggleCompletion(task)
        loadTasks()
    }

    func playTask(_ task: TaskItem) {
        if isCurrentTask(task) && isRunning {
            container.pauseSession()
        } else {
            container.startTaskSession(task: task)
        }
    }

    func showAddTaskForm() {
        isAddingTask = true
    }

    func cancelAddTask() {
        resetForm()
    }

    func isCurrentTask(_ task: TaskItem) -> Bool {
        currentTask?.id == task.id
    }

    var incompleteTasks: [TaskItem] {
        tasks.filter { !$0.isCompleted }
    }

    var completedTasks: [TaskItem] {
        tasks.filter { $0.isCompleted }
    }

    var canAddTask: Bool {
        !newTaskTitle.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func resetForm() {
        newTaskTitle = ""
        newTaskDuration = AppConfiguration.Timer.defaultDurationMinutes
        isAddingTask = false
    }
}
