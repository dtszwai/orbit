import SwiftUI
import SwiftData

struct TasksView: View {
    @ObservedObject var viewModel: TasksViewModel

    var body: some View {
        VStack(spacing: 16) {
            header

            if viewModel.isAddingTask {
                addTaskForm
                    .transition(.move(edge: .top).combined(with: .opacity))
            }

            taskList
        }
        .onAppear {
            viewModel.loadTasks()
        }
    }

    private var header: some View {
        HStack {
            Text("TASKS")
                .font(.system(size: 10, weight: .bold))
                .tracking(1.5)
                .foregroundColor(Theme.Colors.textTertiary)
            Spacer()
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    viewModel.showAddTaskForm()
                }
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 16))
                    .foregroundColor(Theme.Colors.teal)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, AppConfiguration.UI.horizontalPadding)
        .padding(.top, 20)
    }

    private var addTaskForm: some View {
        VStack(spacing: 12) {
            TextField("Task name...", text: $viewModel.newTaskTitle)
                .textFieldStyle(.plain)
                .font(.system(size: 14))
                .padding(12)
                .background(Color.black.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: AppConfiguration.UI.cornerRadius)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
                .cornerRadius(AppConfiguration.UI.cornerRadius)
                .foregroundColor(.white)
                .onSubmit {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        viewModel.addTask()
                    }
                }

            HStack(spacing: 8) {
                durationPicker

                Button("Add") {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        viewModel.addTask()
                    }
                }
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Theme.Colors.teal)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Theme.Colors.teal.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: AppConfiguration.UI.cornerRadius)
                        .stroke(Theme.Colors.teal.opacity(0.2), lineWidth: 1)
                )
                .cornerRadius(AppConfiguration.UI.cornerRadius)
                .buttonStyle(.plain)
                .disabled(!viewModel.canAddTask)
                .opacity(viewModel.canAddTask ? 1.0 : 0.5)
            }
        }
        .padding(.horizontal, AppConfiguration.UI.horizontalPadding)
    }

    private var durationPicker: some View {
        HStack(spacing: 8) {
            Image(systemName: "clock")
                .font(.system(size: 14))
                .foregroundColor(Theme.Colors.textTertiary)

            Picker("", selection: $viewModel.newTaskDuration) {
                ForEach(viewModel.durationOptions, id: \.self) { duration in
                    Text("\(duration)").tag(duration)
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
            .frame(maxWidth: .infinity)

            Text("min")
                .font(.system(size: 12))
                .foregroundColor(Theme.Colors.textTertiary)
        }
        .padding(12)
        .background(Color.black.opacity(0.3))
        .overlay(
            RoundedRectangle(cornerRadius: AppConfiguration.UI.cornerRadius)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .cornerRadius(AppConfiguration.UI.cornerRadius)
    }

    private var taskList: some View {
        ScrollView {
            VStack(spacing: 8) {
                if viewModel.tasks.isEmpty && !viewModel.isAddingTask {
                    emptyState
                }

                ForEach(viewModel.incompleteTasks) { task in
                    TaskRow(
                        task: task,
                        isCurrentTask: viewModel.isCurrentTask(task),
                        isRunning: viewModel.isRunning,
                        onPlay: { viewModel.playTask(task) },
                        onToggleComplete: { viewModel.toggleTaskCompletion(task) },
                        onDelete: { viewModel.deleteTask(task) }
                    )
                }

                if !viewModel.completedTasks.isEmpty {
                    completedSection
                }
            }
            .padding(.horizontal, AppConfiguration.UI.horizontalPadding)
            .padding(.bottom, AppConfiguration.UI.horizontalPadding)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "leaf")
                .font(.system(size: 24))
                .foregroundColor(Color.white.opacity(0.15))
            Text("No tasks yet")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color.white.opacity(0.3))
            Text("Tap + to add your first task")
                .font(.system(size: 12))
                .foregroundColor(Color.white.opacity(0.15))
        }
        .padding(.vertical, 40)
    }

    private var completedSection: some View {
        VStack(spacing: 8) {
            HStack {
                Text("COMPLETED")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1.5)
                    .foregroundColor(Theme.Colors.textTertiary)
                Spacer()
            }
            .padding(.top, 16)

            ForEach(viewModel.completedTasks) { task in
                TaskRow(
                    task: task,
                    isCurrentTask: false,
                    isRunning: false,
                    onPlay: {},
                    onToggleComplete: { viewModel.toggleTaskCompletion(task) },
                    onDelete: { viewModel.deleteTask(task) }
                )
            }
        }
    }
}

struct TaskRow: View {
    let task: TaskItem
    let isCurrentTask: Bool
    let isRunning: Bool
    let onPlay: () -> Void
    let onToggleComplete: () -> Void
    let onDelete: () -> Void

    @State private var isRowHovered = false
    @State private var isPlayHovered = false
    @State private var isDeleteHovered = false

    var body: some View {
        HStack(spacing: 12) {
            checkbox
            taskInfo
            actionButtons
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: AppConfiguration.UI.cornerRadius)
                .fill(task.isCompleted ? Color.white.opacity(0.05) : Theme.Colors.panel)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppConfiguration.UI.cornerRadius)
                .stroke(borderColor, lineWidth: 1)
        )
        .shadow(color: shadowColor, radius: 10)
        .onHover { hovering in
            withAnimation(.easeOut(duration: AppConfiguration.Animation.standardDuration)) {
                isRowHovered = hovering
            }
        }
    }

    private var checkbox: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                onToggleComplete()
            }
        }) {
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
            .frame(width: 32, height: 32)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var taskInfo: some View {
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
    }

    private var actionButtons: some View {
        HStack(spacing: 4) {
            if !task.isCompleted {
                Button(action: onPlay) {
                    Image(systemName: isCurrentTask && isRunning ? "pause.fill" : "play.fill")
                        .font(.system(size: 14))
                        .foregroundColor(isPlayHovered || isCurrentTask ? Theme.Colors.teal : Color.white.opacity(0.3))
                        .frame(width: 32, height: 32)
                        .background(isPlayHovered ? Theme.Colors.teal.opacity(0.15) : Color.white.opacity(0.05))
                        .cornerRadius(AppConfiguration.UI.smallCornerRadius)
                }
                .buttonStyle(.plain)
                .opacity(isRowHovered || isCurrentTask ? 1 : 0.5)
                .onHover { hovering in
                    withAnimation(.easeOut(duration: AppConfiguration.Animation.quickDuration)) {
                        isPlayHovered = hovering
                    }
                }
            }

            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 14))
                    .foregroundColor(isDeleteHovered ? .red : Color.white.opacity(0.3))
                    .frame(width: 32, height: 32)
                    .background(isDeleteHovered ? Color.red.opacity(0.15) : Color.white.opacity(0.05))
                    .cornerRadius(AppConfiguration.UI.smallCornerRadius)
            }
            .buttonStyle(.plain)
            .opacity(isRowHovered ? 1 : 0.5)
            .onHover { hovering in
                withAnimation(.easeOut(duration: AppConfiguration.Animation.quickDuration)) {
                    isDeleteHovered = hovering
                }
            }
        }
    }

    private var borderColor: Color {
        if isCurrentTask && isRunning {
            return Theme.Colors.teal.opacity(0.3)
        } else if task.isCompleted {
            return Color.clear
        } else {
            return Color.white.opacity(0.05)
        }
    }

    private var shadowColor: Color {
        isCurrentTask && isRunning ? Theme.Colors.teal.opacity(0.05) : Color.clear
    }
}
