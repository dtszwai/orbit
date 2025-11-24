import Foundation
import SwiftUI
import Combine

@MainActor
final class StatsViewModel: ObservableObject {
    @Published var selectedWeekOffset: Int = 0
    @Published var sessions: [FocusSession] = []
    @Published var weekDateRange: String = ""
    @Published var totalFocusTime: String = "0m"
    @Published var dailyData: [DailyFocusData] = []

    private let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
    }

    func loadStats() {
        guard let repository = container.sessionRepository else { return }

        sessions = repository.fetchSessions(for: selectedWeekOffset)
        weekDateRange = repository.weekDateRange(for: selectedWeekOffset)

        let totalSeconds = repository.totalFocusTime(for: sessions)
        totalFocusTime = formatDuration(totalSeconds)

        calculateDailyData()
    }

    func previousWeek() {
        selectedWeekOffset -= 1
        loadStats()
    }

    func nextWeek() {
        guard selectedWeekOffset < 0 else { return }
        selectedWeekOffset += 1
        loadStats()
    }

    var canGoNext: Bool {
        selectedWeekOffset < 0
    }

    var maxDailyMinutes: Int {
        dailyData.map { $0.totalMinutes }.max() ?? 1
    }

    private func formatDuration(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }

    private func calculateDailyData() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        let weekday = calendar.component(.weekday, from: today)
        let daysToMonday = (weekday == 1) ? -6 : -(weekday - 2)

        guard let weekStart = calendar.date(
            byAdding: .day,
            value: daysToMonday + (selectedWeekOffset * AppConfiguration.Stats.daysInWeek),
            to: today
        ) else { return }

        let dayLabels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        var data: [DailyFocusData] = []

        for dayIndex in 0..<AppConfiguration.Stats.daysInWeek {
            guard let dayDate = calendar.date(byAdding: .day, value: dayIndex, to: weekStart) else {
                continue
            }

            let dayStart = calendar.startOfDay(for: dayDate)
            guard let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) else {
                continue
            }

            let daySessions = sessions.filter { session in
                session.startTime >= dayStart && session.startTime < dayEnd
            }

            let totalMinutes = daySessions.reduce(0) { $0 + $1.durationSeconds } / 60

            data.append(DailyFocusData(
                dayLabel: dayLabels[dayIndex],
                totalMinutes: totalMinutes,
                isToday: calendar.isDate(dayDate, inSameDayAs: Date())
            ))
        }

        dailyData = data
    }
}

struct DailyFocusData: Identifiable {
    let id = UUID()
    let dayLabel: String
    let totalMinutes: Int
    let isToday: Bool

    var formattedTime: String {
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }

    func heightRatio(maxMinutes: Int) -> Double {
        guard maxMinutes > 0 else { return 0 }
        return Double(totalMinutes) / Double(maxMinutes)
    }
}
