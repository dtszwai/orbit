import Foundation
import Combine
import SwiftUI

final class TimerService: ObservableObject, TimerServiceProtocol {
    @Published private(set) var timeLeft: TimeInterval = AppConfiguration.Timer.defaultDuration
    @Published private(set) var initialDuration: TimeInterval = AppConfiguration.Timer.defaultDuration
    @Published private(set) var isRunning: Bool = false
    @Published private(set) var isPaused: Bool = false

    var progress: Double {
        guard initialDuration > 0 else { return 0 }
        return 1 - (timeLeft / initialDuration)
    }

    var timeFormatted: String {
        let minutes = Int(timeLeft) / 60
        let seconds = Int(timeLeft) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private var timerCancellable: AnyCancellable?
    private(set) var sessionStartTime: Date?

    private let onSessionComplete: (() -> Void)?
    private let onSessionPause: ((TimeInterval) -> Void)?

    init(onSessionComplete: (() -> Void)? = nil,
         onSessionPause: ((TimeInterval) -> Void)? = nil) {
        self.onSessionComplete = onSessionComplete
        self.onSessionPause = onSessionPause
    }

    func start(duration: TimeInterval) {
        timerCancellable?.cancel()
        timeLeft = duration
        initialDuration = duration
        startInternal()
    }

    func pause() {
        guard isRunning else { return }

        timerCancellable?.cancel()
        isRunning = false
        isPaused = true

        if let startTime = sessionStartTime {
            let elapsed = Date().timeIntervalSince(startTime)
            if elapsed >= AppConfiguration.Timer.minimumSessionDuration {
                onSessionPause?(elapsed)
            }
        }
        sessionStartTime = nil
    }

    func resume() {
        guard isPaused else { return }
        startInternal()
    }

    func stop() {
        timerCancellable?.cancel()
        timerCancellable = nil

        isRunning = false
        isPaused = false
        sessionStartTime = nil

        timeLeft = AppConfiguration.Timer.defaultDuration
        initialDuration = AppConfiguration.Timer.defaultDuration
    }

    func setDuration(_ duration: TimeInterval) {
        guard !isRunning && !isPaused else { return }
        timeLeft = duration
        initialDuration = duration
    }

    private func startInternal() {
        isRunning = true
        isPaused = false
        sessionStartTime = Date()

        timerCancellable = Timer.publish(
            every: AppConfiguration.Timer.tickInterval,
            on: .main,
            in: .common
        )
        .autoconnect()
        .sink { [weak self] _ in
            guard let self = self else { return }
            if self.timeLeft > 0 {
                self.timeLeft -= 1
            } else {
                self.finishSession()
            }
        }
    }

    private func finishSession() {
        timerCancellable?.cancel()
        timerCancellable = nil
        isRunning = false
        isPaused = false

        if let startTime = sessionStartTime {
            let elapsed = Date().timeIntervalSince(startTime)
            if elapsed >= AppConfiguration.Timer.minimumSessionDuration {
                onSessionPause?(elapsed)
            }
        }
        sessionStartTime = nil

        onSessionComplete?()

        timeLeft = AppConfiguration.Timer.defaultDuration
        initialDuration = AppConfiguration.Timer.defaultDuration
    }
}
