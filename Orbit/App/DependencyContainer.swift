import Foundation
import SwiftUI
import SwiftData
import Combine

@MainActor
final class DependencyContainer: ObservableObject {
    let timerService: TimerService
    let audioService: AudioService
    let bioRhythmService: BioRhythmService

    private(set) var sessionRepository: SessionRepository?
    private(set) var taskRepository: TaskRepository?

    @Published var currentTask: TaskItem?

    private var cancellables = Set<AnyCancellable>()

    init() {
        self.audioService = AudioService()
        self.bioRhythmService = BioRhythmService()
        self.timerService = TimerService()

        timerService.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    func configure(with context: ModelContext) {
        self.sessionRepository = SessionRepository(context: context)
        self.taskRepository = TaskRepository(context: context)
    }

    func startFocusSession(duration: TimeInterval? = nil) {
        let sessionDuration = duration ?? AppConfiguration.Timer.defaultDuration
        timerService.start(duration: sessionDuration)
    }

    func startTaskSession(task: TaskItem) {
        currentTask = task
        let duration = TimeInterval(task.durationMinutes * 60)
        timerService.start(duration: duration)
    }

    func pauseSession() {
        timerService.pause()
        saveCurrentSession()
    }

    func stopSession() {
        if timerService.isRunning || timerService.isPaused {
            saveCurrentSession()
        }
        timerService.stop()
        currentTask = nil
    }

    func toggleTimer() {
        if timerService.isRunning {
            pauseSession()
        } else if timerService.isPaused {
            timerService.resume()
        } else {
            startFocusSession()
        }
    }

    private func saveCurrentSession() {
        guard let startTime = timerService.sessionStartTime else { return }

        let elapsed = Date().timeIntervalSince(startTime)
        guard elapsed >= AppConfiguration.Timer.minimumSessionDuration else { return }

        let session = FocusSession(
            durationSeconds: Int(elapsed),
            taskTitle: currentTask?.title
        )

        try? sessionRepository?.save(session)
    }

    func generateMockData() {
        sessionRepository?.generateMockData()
    }

    func clearAllData() {
        try? sessionRepository?.deleteAll()
    }
}
