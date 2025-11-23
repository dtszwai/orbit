import SwiftUI
import Combine
import SwiftData

// MARK: - Global State Manager
class OrbitManager: ObservableObject {
    // Timer State
    @Published var timeLeft: TimeInterval = 25 * 60
    @Published var isRunning: Bool = false
    @Published var isPaused: Bool = false
    @Published var currentTask: TaskItem?

    // Audio State
    @Published var activeSoundscape: Soundscape = .focus
    @Published var volume: Double = 0.75
    @Published var isMuted: Bool = false
    var volumeBeforeMute: Double = 0.75

    // Bio-Rhythm State
    @Published var energyStatus: String = "Calculating..."

    // Stats State
    @Published var selectedWeekOffset: Int = 0

    private var timerCancellable: AnyCancellable?
    private var sessionStartTime: Date?
    var modelContext: ModelContext?
    
    enum Soundscape: String, CaseIterable {
        case focus = "Zap"
        case natural = "Wind"
        case spatial = "Moon"
        case relax = "Coffee"

        var color: Color {
            switch self {
            case .focus: return Theme.Colors.teal
            case .natural: return Theme.Colors.green
            case .spatial: return Theme.Colors.purple
            case .relax: return Theme.Colors.amber
            }
        }

        var icon: String {
            switch self {
            case .focus: return "bolt.fill"
            case .natural: return "wind"
            case .spatial: return "moon.stars.fill"
            case .relax: return "cup.and.saucer.fill"
            }
        }

        var label: String {
            switch self {
            case .focus: return "Deep Work"
            case .natural: return "Natural"
            case .spatial: return "Spatial"
            case .relax: return "Relax"
            }
        }
    }
    
    init() {
        updateBioRhythm()
    }
    
    // MARK: - Timer Logic
    var defaultDuration: TimeInterval {
        return 25 * 60
    }

    func setDuration(minutes: Int) {
        if !isRunning {
            timeLeft = TimeInterval(minutes * 60)
        }
    }

    func toggleTimer() {
        if isRunning {
            pauseTimer()
        } else {
            startTimer()
        }
    }

    func stopTimer() {
        if isRunning {
            pauseTimer()
        }
        timeLeft = defaultDuration // Reset to default
        currentTask = nil
        isPaused = false
    }

    private func startTimer() {
        isRunning = true
        isPaused = false
        sessionStartTime = Date()
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.timeLeft > 0 {
                    self.timeLeft -= 1
                } else {
                    self.finishSession()
                }
            }
        // TODO: Trigger Audio Engine Fade In
    }

    private func pauseTimer() {
        isRunning = false
        isPaused = true
        timerCancellable?.cancel()

        // Save session if at least 1 minute was completed
        if let startTime = sessionStartTime {
            let elapsed = Date().timeIntervalSince(startTime)
            if elapsed >= 60 {
                saveSession(durationSeconds: Int(elapsed))
            }
        }
        sessionStartTime = nil
        // TODO: Trigger Audio Engine Ducking
    }

    private func finishSession() {
        pauseTimer()
        timeLeft = 25 * 60 // Reset
        isPaused = false
    }

    private func saveSession(durationSeconds: Int) {
        guard let context = modelContext else { return }
        let session = FocusSession(
            durationSeconds: durationSeconds,
            taskTitle: currentTask?.title
        )
        context.insert(session)
        try? context.save()
    }
    
    // MARK: - Task Logic
    func playTask(_ task: TaskItem) {
        currentTask = task
        timeLeft = TimeInterval(task.durationMinutes * 60)
        startTimer()
    }
    
    // MARK: - Bio-Rhythm Logic (Mock)
    func updateBioRhythm() {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour >= 13 && hour < 16 {
            energyStatus = "Afternoon Decay (Low Energy)"
        } else if hour >= 16 {
            energyStatus = "Evening Recovery"
        } else {
            energyStatus = "Morning Peak"
        }
    }
    
    // MARK: - Helpers
    var timeFormatted: String {
        let minutes = Int(timeLeft) / 60
        let seconds = Int(timeLeft) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    // MARK: - Stats Queries
    func fetchSessions(for weekOffset: Int = 0) -> [FocusSession] {
        guard let context = modelContext else { return [] }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Calculate the start of the week (Monday)
        let weekday = calendar.component(.weekday, from: today)
        let daysToMonday = (weekday == 1) ? -6 : -(weekday - 2)
        guard let weekStart = calendar.date(byAdding: .day, value: daysToMonday + (weekOffset * 7), to: today) else {
            return []
        }
        guard let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart) else {
            return []
        }

        let descriptor = FetchDescriptor<FocusSession>(
            predicate: #Predicate { session in
                session.startTime >= weekStart && session.startTime < weekEnd
            },
            sortBy: [SortDescriptor(\.startTime)]
        )

        return (try? context.fetch(descriptor)) ?? []
    }

    func totalFocusTime(for sessions: [FocusSession]) -> TimeInterval {
        sessions.reduce(0) { $0 + TimeInterval($1.durationSeconds) }
    }

    func formatDuration(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        return String(format: "%dh %02dm", hours, minutes)
    }

    func weekDateRange(offset: Int = 0) -> String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        let weekday = calendar.component(.weekday, from: today)
        let daysToMonday = (weekday == 1) ? -6 : -(weekday - 2)
        guard let weekStart = calendar.date(byAdding: .day, value: daysToMonday + (offset * 7), to: today),
              let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) else {
            return "Select Week"
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"

        let startStr = formatter.string(from: weekStart)
        let endStr = formatter.string(from: weekEnd)

        return "\(startStr) - \(endStr)"
    }

    // MARK: - Mock Data Generator
    func generateMockData() {
        guard let context = modelContext else { return }

        let calendar = Calendar.current
        let now = Date()

        // Generate sessions for the past 3 weeks
        for daysAgo in 0..<21 {
            guard let date = calendar.date(byAdding: .day, value: -daysAgo, to: now) else { continue }

            // Random number of sessions per day (0-4)
            let sessionCount = Int.random(in: 0...4)

            for _ in 0..<sessionCount {
                // Random hour in the day
                let hour = Int.random(in: 6...22)
                let minute = Int.random(in: 0...59)

                guard let sessionStart = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: date) else {
                    continue
                }

                // Random duration (15 min to 2 hours)
                let duration = Int.random(in: 15...120) * 60

                let session = FocusSession(durationSeconds: duration, taskTitle: nil)
                session.startTime = sessionStart
                context.insert(session)
            }
        }

        try? context.save()
        print("✅ Generated mock data for past 3 weeks")
    }

    func clearAllData() {
        guard let context = modelContext else { return }

        let descriptor = FetchDescriptor<FocusSession>()
        let sessions = (try? context.fetch(descriptor)) ?? []

        for session in sessions {
            context.delete(session)
        }

        try? context.save()
        print("🗑️ Cleared all session data")
    }
}