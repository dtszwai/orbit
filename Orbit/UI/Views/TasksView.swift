import SwiftUI
import SwiftData

// MARK: - Tab 2: Tasks
struct TasksView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TaskItem.createdAt, order: .reverse) private var tasks: [TaskItem]
    @ObservedObject var manager: OrbitManager
    @State private var newTaskTitle = ""
    @State private var newTaskDuration = "25"
    @State private var isAdding = false

    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text("TODAY'S MISSION")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1.5)
                    .foregroundColor(Theme.Colors.textTertiary)
                Spacer()
                Button(action: { withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { isAdding.toggle() }}) {
                    Image(systemName: "plus")
                        .font(.system(size: 16))
                        .foregroundColor(Theme.Colors.teal)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)

            // Add Task Form
            if isAdding {
                VStack(spacing: 12) {
                    TextField("Task name...", text: $newTaskTitle)
                        .textFieldStyle(.plain)
                        .font(.system(size: 14))
                        .padding(12)
                        .background(Color.black.opacity(0.3))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                        .cornerRadius(12)
                        .foregroundColor(.white)
                        .onSubmit { addTask() }

                    HStack(spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: "clock")
                                .font(.system(size: 14))
                                .foregroundColor(Theme.Colors.textTertiary)
                            TextField("25", text: $newTaskDuration)
                                .textFieldStyle(.plain)
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                            Text("min")
                                .font(.system(size: 12))
                                .foregroundColor(Theme.Colors.textTertiary)
                        }
                        .padding(12)
                        .background(Color.black.opacity(0.3))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                        .cornerRadius(12)

                        Button("Add") { addTask() }
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Theme.Colors.teal)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Theme.Colors.teal.opacity(0.2))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Theme.Colors.teal.opacity(0.2), lineWidth: 1)
                            )
                            .cornerRadius(12)
                            .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 24)
                .transition(.move(edge: .top).combined(with: .opacity))
            }

            // Task List
            ScrollView {
                VStack(spacing: 8) {
                    if tasks.isEmpty && !isAdding {
                        Text("No tasks yet. Add one to start flowing.")
                            .font(.system(size: 14))
                            .foregroundColor(Color.white.opacity(0.2))
                            .padding(.vertical, 32)
                    }

                    ForEach(tasks) { task in
                        TaskRow(task: task, manager: manager, onDelete: { deleteTask(task) })
                    }
                }
                .padding(.horizontal, 24)
            }
        }
    }

    private func addTask() {
        guard !newTaskTitle.isEmpty else { return }
        let duration = Int(newTaskDuration) ?? 25
        let newItem = TaskItem(title: newTaskTitle, durationMinutes: duration)
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            modelContext.insert(newItem)
            newTaskTitle = ""
            newTaskDuration = "25"
            isAdding = false
        }
    }

    private func deleteTask(_ task: TaskItem) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            modelContext.delete(task)
        }
    }
}

// MARK: - Task Row Component
struct TaskRow: View {
    let task: TaskItem
    @ObservedObject var manager: OrbitManager
    let onDelete: () -> Void
    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 12) {
            // Checkbox
            Button(action: { withAnimation { task.isCompleted.toggle() }}) {
                ZStack {
                    Circle()
                        .stroke(task.isCompleted ? Theme.Colors.teal : Color.white.opacity(0.2), lineWidth: 1.5)
                        .frame(width: 18, height: 18)
                    if task.isCompleted {
                        Circle()
                            .fill(Theme.Colors.teal)
                            .frame(width: 18, height: 18)
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.black)
                    }
                }
            }
            .buttonStyle(.plain)

            // Task Info
            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(task.isCompleted ? Color.white.opacity(0.4) : Color.white.opacity(0.9))
                    .strikethrough(task.isCompleted)
                Text("\(task.durationMinutes) min")
                    .font(.system(size: 10))
                    .foregroundColor(Theme.Colors.textTertiary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Actions
            HStack(spacing: 4) {
                if !task.isCompleted {
                    Button(action: { manager.playTask(task) }) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 14))
                            .foregroundColor(Theme.Colors.teal)
                            .frame(width: 32, height: 32)
                            .background(Theme.Colors.teal.opacity(0.1))
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                    .opacity(isHovered ? 1 : 0)
                }

                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 14))
                        .foregroundColor(.red.opacity(0.7))
                        .frame(width: 32, height: 32)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
                .opacity(isHovered ? 1 : 0)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(task.isCompleted ? Color.white.opacity(0.05) : Theme.Colors.panel)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    manager.currentTask?.id == task.id && manager.isRunning
                        ? Theme.Colors.teal.opacity(0.3)
                        : task.isCompleted ? Color.clear : Color.white.opacity(0.05),
                    lineWidth: 1
                )
        )
        .shadow(
            color: manager.currentTask?.id == task.id && manager.isRunning
                ? Theme.Colors.teal.opacity(0.05)
                : Color.clear,
            radius: 10
        )
        .onHover { hovering in
            withAnimation(.easeOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
    }
}
