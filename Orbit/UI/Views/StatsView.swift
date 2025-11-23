import SwiftUI
import SwiftData

// MARK: - Tab 3: Stats
struct StatsView: View {
    @ObservedObject var manager: OrbitManager
    @State private var hoveredCellIndex: Int?
    @State private var displayTime: String = ""
    @State private var displayLabel: String = "TOTAL FOCUS"
    @State private var sessions: [FocusSession] = []
    @State private var dailyStats: [DailyStats] = []
    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 24) {
            // Header with Navigation
            HStack {
                Button(action: {
                    withAnimation(.easeOut(duration: 0.2)) {
                        manager.selectedWeekOffset -= 1
                        loadStats()
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.5))
                        .frame(width: 28, height: 28)
                        .background(Color.white.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .buttonStyle(.plain)

                Spacer()

                Text(manager.weekDateRange(offset: manager.selectedWeekOffset))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.6))
                    .contentTransition(.numericText())

                Spacer()

                Button(action: {
                    withAnimation(.easeOut(duration: 0.2)) {
                        manager.selectedWeekOffset += 1
                        loadStats()
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.5))
                        .frame(width: 28, height: 28)
                        .background(Color.white.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .buttonStyle(.plain)
                .disabled(manager.selectedWeekOffset >= 0)
                .opacity(manager.selectedWeekOffset >= 0 ? 0.2 : 1.0)
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)

            // Total Focus Time with Animation
            VStack(spacing: 6) {
                Text(displayLabel)
                    .font(.system(size: 11, weight: .semibold))
                    .tracking(1.5)
                    .foregroundColor(Color.white.opacity(0.4))
                    .animation(.easeOut(duration: 0.2), value: displayLabel)

                Text(displayTime)
                    .font(.system(size: 56, weight: .medium))
                    .tracking(-2)
                    .foregroundColor(.white)
                    .contentTransition(.numericText())
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: displayTime)
            }
            .frame(height: 80)

            // Heatmap Grid with Hover
            VStack(spacing: 12) {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 8) {
                    ForEach(Array(dailyStats.enumerated()), id: \.offset) { index, stat in
                        HeatmapCell(
                            stat: stat,
                            isHovered: hoveredCellIndex == index,
                            index: index,
                            isAnimating: isAnimating
                        )
                        .onHover { isHovering in
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                                if isHovering {
                                    hoveredCellIndex = index
                                    displayTime = manager.formatDuration(stat.totalSeconds)
                                    displayLabel = formatDateLabel(for: stat.date)
                                } else if hoveredCellIndex == index {
                                    hoveredCellIndex = nil
                                    displayTime = manager.formatDuration(totalFocusTime())
                                    displayLabel = "TOTAL FOCUS"
                                }
                            }
                        }
                    }
                }

                // Day Labels
                HStack(spacing: 0) {
                    ForEach(["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"], id: \.self) { day in
                        Text(day)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(Color.white.opacity(0.35))
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.top, 8)
            }
            .padding(.horizontal, 24)

            // Time Period Breakdown
            HStack(spacing: 0) {
                ForEach(["Morning", "Afternoon", "Evening"], id: \.self) { period in
                    VStack(spacing: 6) {
                        Text(period)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(Color.white.opacity(0.35))

                        Text(periodTime(for: period))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color.white.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 24)

            Spacer()
        }
        .onAppear {
            loadStats()
            // Trigger animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation {
                    isAnimating = true
                }
            }
        }
        .onChange(of: manager.selectedWeekOffset) { _, _ in
            loadStats()
        }
    }

    private func loadStats() {
        sessions = manager.fetchSessions(for: manager.selectedWeekOffset)
        dailyStats = calculateDailyStats()
        displayTime = manager.formatDuration(totalFocusTime())
        displayLabel = "TOTAL FOCUS"
    }

    private func formatDateLabel(for date: Date) -> String {
        let formatter = DateFormatter()

        // Get day of week (SUN, MON, etc)
        formatter.dateFormat = "EEE"
        let dayName = formatter.string(from: date).uppercased()

        // Get month and day (NOV 23)
        formatter.dateFormat = "MMM d"
        let dateStr = formatter.string(from: date).uppercased()

        return "\(dayName) · \(dateStr)"
    }

    private func calculateDailyStats() -> [DailyStats] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Calculate week start
        let weekday = calendar.component(.weekday, from: today)
        let daysToMonday = (weekday == 1) ? -6 : -(weekday - 2)
        guard let weekStart = calendar.date(byAdding: .day, value: daysToMonday + (manager.selectedWeekOffset * 7), to: today) else {
            return []
        }

        var stats: [DailyStats] = []

        for dayOffset in 0..<21 {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: weekStart) else {
                continue
            }

            let daySessions = sessions.filter {
                calendar.isDate($0.startTime, inSameDayAs: date)
            }

            let totalSeconds = daySessions.reduce(0.0) { $0 + TimeInterval($1.durationSeconds) }
            let intensity = min(totalSeconds / (4 * 3600), 1.0) // Cap at 4 hours for max intensity

            stats.append(DailyStats(
                date: date,
                totalSeconds: totalSeconds,
                sessionCount: daySessions.count,
                intensity: intensity
            ))
        }

        return stats
    }

    private func totalFocusTime() -> TimeInterval {
        dailyStats.reduce(0) { $0 + $1.totalSeconds }
    }

    private func periodTime(for period: String) -> String {
        let periodSessions: [FocusSession]

        switch period {
        case "Morning":
            periodSessions = sessions.filter { session in
                let hour = Calendar.current.component(.hour, from: session.startTime)
                return hour >= 5 && hour < 12
            }
        case "Afternoon":
            periodSessions = sessions.filter { session in
                let hour = Calendar.current.component(.hour, from: session.startTime)
                return hour >= 12 && hour < 17
            }
        case "Evening":
            periodSessions = sessions.filter { session in
                let hour = Calendar.current.component(.hour, from: session.startTime)
                return hour >= 17 || hour < 5
            }
        default:
            return "0h"
        }

        let total = periodSessions.reduce(0.0) { $0 + TimeInterval($1.durationSeconds) }
        let hours = Int(total) / 3600
        return "\(hours)h"
    }
}

// MARK: - Daily Stats Model
struct DailyStats {
    let date: Date
    let totalSeconds: TimeInterval
    let sessionCount: Int
    let intensity: Double
}

// MARK: - Heatmap Cell Component
struct HeatmapCell: View {
    let stat: DailyStats
    let isHovered: Bool
    let index: Int
    let isAnimating: Bool

    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(cellColor)
            .frame(height: 30)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .strokeBorder(
                        isHovered ? Color.white.opacity(0.3) : Color.clear,
                        lineWidth: 1.5
                    )
            )
            .scaleEffect(isAnimating ? 1.0 : 0.9)
            .opacity(isAnimating ? 1.0 : 0.0)
            .animation(
                .easeOut(duration: 0.3)
                .delay(Double(index) * 0.015),
                value: isAnimating
            )
            .animation(.easeOut(duration: 0.15), value: isHovered)
    }

    private var cellColor: Color {
        // Show color for any time > 0
        if stat.totalSeconds == 0 {
            return Color.white.opacity(0.03)
        } else if stat.intensity > 0.7 {
            return Theme.Colors.teal
        } else if stat.intensity > 0.5 {
            return Theme.Colors.teal.opacity(0.65)
        } else if stat.intensity > 0.3 {
            return Theme.Colors.teal.opacity(0.35)
        } else if stat.intensity > 0.1 {
            return Theme.Colors.teal.opacity(0.2)
        } else {
            // Any session time, even 1 minute, gets a subtle teal
            return Theme.Colors.teal.opacity(0.12)
        }
    }
}
