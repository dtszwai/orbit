import Foundation
import SwiftData

// MARK: - Session Repository
/// Repository for managing FocusSession data persistence
final class SessionRepository: SessionRepositoryProtocol {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func save(_ session: FocusSession) throws {
        context.insert(session)
        try context.save()
    }

    func fetchSessions(for weekOffset: Int) -> [FocusSession] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Calculate the start of the week (Monday)
        let weekday = calendar.component(.weekday, from: today)
        let daysToMonday = (weekday == 1) ? -6 : -(weekday - 2)

        guard let weekStart = calendar.date(byAdding: .day, value: daysToMonday + (weekOffset * 7), to: today),
              let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart) else {
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

    func deleteAll() throws {
        let descriptor = FetchDescriptor<FocusSession>()
        let sessions = (try? context.fetch(descriptor)) ?? []

        for session in sessions {
            context.delete(session)
        }

        try context.save()
    }

    func totalFocusTime(for sessions: [FocusSession]) -> TimeInterval {
        sessions.reduce(0) { $0 + TimeInterval($1.durationSeconds) }
    }

    func weekDateRange(for offset: Int) -> String {
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

    // MARK: - Mock Data Generation
    func generateMockData() {
        let calendar = Calendar.current
        let now = Date()

        for daysAgo in 0..<(AppConfiguration.Stats.mockDataWeeks * 7) {
            guard let date = calendar.date(byAdding: .day, value: -daysAgo, to: now) else { continue }

            let sessionCount = Int.random(in: 0...4)

            for _ in 0..<sessionCount {
                let hour = Int.random(in: 6...22)
                let minute = Int.random(in: 0...59)

                guard let sessionStart = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: date) else {
                    continue
                }

                let duration = Int.random(in: 15...120) * 60

                let session = FocusSession(durationSeconds: duration, taskTitle: nil)
                session.startTime = sessionStart
                context.insert(session)
            }
        }

        try? context.save()
    }
}
