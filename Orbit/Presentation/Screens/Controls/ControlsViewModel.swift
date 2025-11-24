import Foundation
import SwiftUI
import Combine

@MainActor
final class ControlsViewModel: ObservableObject {
    @Published var timeFormatted: String = "25:00"
    @Published var progress: Double = 0
    @Published var isRunning: Bool = false
    @Published var isPaused: Bool = false
    @Published var statusText: String = "READY TO FLOW"
    @Published var currentTaskTitle: String?

    @Published var activeSoundscape: Soundscape = .focus
    @Published var volume: Double = AppConfiguration.Audio.defaultVolume
    @Published var isMuted: Bool = false

    private let container: DependencyContainer
    private var cancellables = Set<AnyCancellable>()

    init(container: DependencyContainer) {
        self.container = container
        bindToServices()
    }

    private func bindToServices() {
        container.timerService.$timeLeft
            .map { timeLeft in
                let minutes = Int(timeLeft) / 60
                let seconds = Int(timeLeft) % 60
                return String(format: "%02d:%02d", minutes, seconds)
            }
            .assign(to: &$timeFormatted)

        container.timerService.$isRunning
            .assign(to: &$isRunning)

        container.timerService.$isPaused
            .assign(to: &$isPaused)

        Publishers.CombineLatest3(
            container.timerService.$isRunning,
            container.timerService.$isPaused,
            container.$currentTask
        )
        .map { isRunning, isPaused, currentTask in
            if isRunning {
                return currentTask?.title.uppercased() ?? "FLOW STATE ACTIVE"
            } else if isPaused {
                return "PAUSED"
            } else {
                return "READY TO FLOW"
            }
        }
        .assign(to: &$statusText)

        Publishers.CombineLatest(
            container.timerService.$timeLeft,
            container.timerService.$initialDuration
        )
        .map { timeLeft, initialDuration in
            guard initialDuration > 0 else { return 0.0 }
            return 1 - (timeLeft / initialDuration)
        }
        .assign(to: &$progress)

        container.$currentTask
            .map { $0?.title }
            .assign(to: &$currentTaskTitle)

        container.audioService.$activeSoundscape
            .assign(to: &$activeSoundscape)

        container.audioService.$volume
            .assign(to: &$volume)

        container.audioService.$isMuted
            .assign(to: &$isMuted)
    }

    func toggleTimer() {
        container.toggleTimer()
    }

    func stopTimer() {
        container.stopSession()
    }

    func setDuration(minutes: Int) {
        container.timerService.setDuration(TimeInterval(minutes * 60))
    }

    func selectSoundscape(_ soundscape: Soundscape) {
        container.audioService.activeSoundscape = soundscape
    }

    func setVolume(_ newVolume: Double) {
        container.audioService.setVolume(newVolume)
    }

    func toggleMute() {
        container.audioService.toggleMute()
    }
}
