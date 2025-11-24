import Foundation

// MARK: - Audio Service Protocol
/// Protocol defining the interface for audio/soundscape functionality
protocol AudioServiceProtocol: ObservableObject {
    /// Currently active soundscape
    var activeSoundscape: Soundscape { get set }

    /// Current volume level (0.0 to 1.0)
    var volume: Double { get set }

    /// Whether audio is muted
    var isMuted: Bool { get set }

    /// Play the active soundscape
    func play()

    /// Pause playback
    func pause()

    /// Stop playback
    func stop()

    /// Fade in audio
    func fadeIn(duration: TimeInterval)

    /// Fade out audio (ducking)
    func fadeOut(duration: TimeInterval)

    /// Toggle mute state
    func toggleMute()
}
