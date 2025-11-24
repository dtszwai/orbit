import SwiftUI

struct StatsView: View {
    @ObservedObject var viewModel: StatsViewModel
    @State private var hoveredDayIndex: Int?
    @State private var displayTime: String = ""
    @State private var displayLabel: String = "TOTAL FOCUS"
    @State private var isAnimating = false
    @State private var hasAppeared = false

    var body: some View {
        VStack(spacing: 16) {
            weekNavigator
            totalFocusDisplay
            barChart

            Spacer(minLength: 0)
        }
        .onAppear {
            viewModel.loadStats()
            displayTime = viewModel.totalFocusTime

            if !hasAppeared {
                hasAppeared = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation {
                        isAnimating = true
                    }
                }
            } else {
                isAnimating = true
            }
        }
    }

    private var weekNavigator: some View {
        HStack {
            Button(action: {
                withAnimation(.easeOut(duration: AppConfiguration.Animation.standardDuration)) {
                    viewModel.previousWeek()
                    displayTime = viewModel.totalFocusTime
                    displayLabel = "TOTAL FOCUS"
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

            Text(viewModel.weekDateRange)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color.white.opacity(0.6))
                .contentTransition(.numericText())

            Spacer()

            Button(action: {
                withAnimation(.easeOut(duration: AppConfiguration.Animation.standardDuration)) {
                    viewModel.nextWeek()
                    displayTime = viewModel.totalFocusTime
                    displayLabel = "TOTAL FOCUS"
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
            .disabled(!viewModel.canGoNext)
            .opacity(viewModel.canGoNext ? 1.0 : 0.2)
        }
        .padding(.horizontal, AppConfiguration.UI.horizontalPadding)
        .padding(.top, 20)
    }

    private var totalFocusDisplay: some View {
        VStack(spacing: 4) {
            Text(displayLabel)
                .font(.system(size: 10, weight: .semibold))
                .tracking(1.2)
                .foregroundColor(Color.white.opacity(0.4))
                .animation(.easeOut(duration: AppConfiguration.Animation.standardDuration), value: displayLabel)

            Text(displayTime)
                .font(.system(size: 42, weight: .medium))
                .tracking(-1.5)
                .foregroundColor(.white)
                .contentTransition(.numericText())
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: displayTime)
        }
        .frame(height: 60)
    }

    private var barChart: some View {
        VStack(spacing: 8) {
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(Array(viewModel.dailyData.enumerated()), id: \.offset) { index, data in
                    BarColumn(
                        data: data,
                        maxMinutes: viewModel.maxDailyMinutes,
                        isHovered: hoveredDayIndex == index,
                        index: index,
                        isAnimating: isAnimating
                    )
                    .onHover { isHovering in
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                            if isHovering {
                                hoveredDayIndex = index
                                displayTime = data.formattedTime
                                displayLabel = data.dayLabel.uppercased()
                            } else if hoveredDayIndex == index {
                                hoveredDayIndex = nil
                                displayTime = viewModel.totalFocusTime
                                displayLabel = "TOTAL FOCUS"
                            }
                        }
                    }
                }
            }
            .frame(height: 100)
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(Color.white.opacity(0.03))
            .clipShape(RoundedRectangle(cornerRadius: AppConfiguration.UI.cornerRadius))

            HStack(spacing: 0) {
                ForEach(viewModel.dailyData) { data in
                    Text(data.dayLabel)
                        .font(.system(size: 9, weight: data.isToday ? .bold : .medium))
                        .foregroundColor(data.isToday ? Theme.Colors.teal : Color.white.opacity(0.35))
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.top, 4)
        }
        .padding(.horizontal, AppConfiguration.UI.horizontalPadding)
        .padding(.bottom, AppConfiguration.UI.horizontalPadding)
    }
}

private struct BarColumn: View {
    let data: DailyFocusData
    let maxMinutes: Int
    let isHovered: Bool
    let index: Int
    let isAnimating: Bool

    private let maxBarHeight: CGFloat = 100
    private let fourHoursInMinutes: Double = 4.0 * 60.0

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)

            RoundedRectangle(cornerRadius: 4)
                .fill(barColor)
                .frame(maxWidth: .infinity)
                .frame(height: barHeight)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .strokeBorder(borderColor, lineWidth: 1.5)
                )
                .scaleEffect(x: 1.0, y: isAnimating ? 1.0 : 0.0, anchor: .bottom)
                .opacity(isAnimating ? 1.0 : 0.0)
                .animation(
                    .spring(response: 0.6, dampingFraction: 0.7)
                    .delay(Double(index) * 0.08),
                    value: isAnimating
                )
                .animation(.easeOut(duration: AppConfiguration.Animation.quickDuration), value: isHovered)
        }
    }

    private var barHeight: CGFloat {
        guard maxMinutes > 0 else { return 3 }
        let normalizedHeight = CGFloat(data.totalMinutes) / CGFloat(maxMinutes)
        let minHeight: CGFloat = data.totalMinutes > 0 ? 6 : 3
        return max(minHeight, normalizedHeight * maxBarHeight)
    }

    private var barColor: Color {
        guard data.totalMinutes > 0 else {
            return Color.white.opacity(0.05)
        }

        let intensity = Double(data.totalMinutes) / fourHoursInMinutes
        if intensity > 0.7 {
            return Theme.Colors.teal
        } else if intensity > 0.5 {
            return Theme.Colors.teal.opacity(0.7)
        } else if intensity > 0.3 {
            return Theme.Colors.teal.opacity(0.45)
        } else if intensity > 0.1 {
            return Theme.Colors.teal.opacity(0.25)
        } else {
            return Theme.Colors.teal.opacity(0.15)
        }
    }

    private var borderColor: Color {
        if isHovered {
            return Color.white.opacity(0.3)
        } else if data.isToday {
            return Theme.Colors.teal.opacity(0.4)
        } else {
            return Color.clear
        }
    }
}
