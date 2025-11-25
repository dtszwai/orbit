import SwiftUI

struct ControlsView: View {
    @ObservedObject var viewModel: ControlsViewModel

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)

            VStack(spacing: 16) {
                statusIndicator
                progressRing
                actionButtons
            }
            .padding(.horizontal, AppConfiguration.UI.horizontalPadding)
            .padding(.bottom, AppConfiguration.UI.horizontalPadding)

            Spacer(minLength: 0)
        }
    }

    private var statusIndicator: some View {
        Text(viewModel.statusText)
            .font(.system(size: 12, weight: .bold))
            .tracking(2)
            .foregroundColor(viewModel.isRunning ? Theme.Colors.teal : Theme.Colors.textTertiary)
            .lineLimit(1)
            .truncationMode(.tail)
            .padding(.horizontal, AppConfiguration.UI.horizontalPadding)
            .padding(.top, 20)
            .animation(.easeOut(duration: AppConfiguration.Animation.slowDuration), value: viewModel.isRunning)
    }

    private var progressRing: some View {
        ProgressRing(
            progress: viewModel.progress,
            isActive: viewModel.isRunning || viewModel.isPaused,
            timeFormatted: viewModel.timeFormatted
        )
        .padding(.bottom, 8)
    }

    @ViewBuilder
    private var actionButtons: some View {
        if viewModel.isRunning {
            runningButtons
                .transition(.opacity)
        } else if viewModel.isPaused {
            pausedButtons
                .transition(.opacity)
        } else {
            startButton
                .transition(.opacity)
        }
    }

    private var runningButtons: some View {
        HStack(spacing: 12) {
            ActionButton(
                title: "Pause",
                icon: "pause.fill",
                color: Theme.Colors.amber,
                style: .outlined
            ) {
                viewModel.toggleTimer()
            }

            ActionButton(
                title: "Stop",
                icon: "stop.fill",
                color: .red.opacity(0.8),
                style: .outlined
            ) {
                viewModel.stopTimer()
            }
        }
    }

    private var pausedButtons: some View {
        HStack(spacing: 12) {
            ActionButton(
                title: "Resume",
                icon: "play.fill",
                color: Theme.Colors.amber,
                style: .filled
            ) {
                viewModel.toggleTimer()
            }

            ActionButton(
                title: "Stop",
                icon: "stop.fill",
                color: .red.opacity(0.8),
                style: .outlined
            ) {
                viewModel.stopTimer()
            }
        }
    }

    private var startButton: some View {
        ActionButton(
            title: "Start Focus",
            icon: "play.fill",
            color: Theme.Colors.teal,
            style: .filled
        ) {
            viewModel.toggleTimer()
        }
    }
}

private struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let style: ButtonStyle
    let action: () -> Void

    enum ButtonStyle {
        case filled
        case outlined
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .tracking(0.5)
            }
            .foregroundColor(foregroundColor)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(background)
            .overlay(overlay)
            .shadow(color: shadowColor, radius: 8)
            .contentShape(RoundedRectangle(cornerRadius: AppConfiguration.UI.cornerRadius))
        }
        .buttonStyle(.plain)
    }

    private var foregroundColor: Color {
        switch style {
        case .filled: return .black
        case .outlined: return color
        }
    }

    private var background: some View {
        RoundedRectangle(cornerRadius: AppConfiguration.UI.cornerRadius)
            .fill(style == .filled ? color : color.opacity(0.1))
    }

    @ViewBuilder
    private var overlay: some View {
        if style == .outlined {
            RoundedRectangle(cornerRadius: AppConfiguration.UI.cornerRadius)
                .stroke(color.opacity(0.2), lineWidth: 1)
        }
    }

    private var shadowColor: Color {
        style == .filled ? color.opacity(0.2) : .clear
    }
}
