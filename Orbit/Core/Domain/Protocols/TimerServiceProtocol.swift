import Foundation
import Combine

// MARK: - Timer Service Protocol
/// Protocol defining the interface for timer functionality
protocol TimerServiceProtocol: ObservableObject {
    /// Remaining time in seconds
    var timeLeft: TimeInterval { get }

    /// Initial duration of the timer
    var initialDuration: TimeInterval { get }

    /// Whether the timer is currently running
    var isRunning: Bool { get }

    /// Whether the timer is paused
    var isPaused: Bool { get }

    /// Progress from 0.0 to 1.0
    var progress: Double { get }

    /// Formatted time string (MM:SS)
    var timeFormatted: String { get }

    /// Start the timer with a specific duration
    func start(duration: TimeInterval)

    /// Pause the timer
    func pause()

    /// Resume a paused timer
    func resume()

    /// Stop and reset the timer
    func stop()

    /// Set the duration (only works when not running)
    func setDuration(_ duration: TimeInterval)
}
