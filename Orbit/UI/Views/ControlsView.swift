import SwiftUI
import SwiftData

// MARK: - Tab 1: Controls (The Cockpit)
struct ControlsView: View {
    @ObservedObject var manager: OrbitManager

    var body: some View {
        VStack(spacing: 0) {
            // Timer Section
            VStack(spacing: 16) {
                // Status Indicator
                Text(manager.isRunning ? "FLOW STATE ACTIVE" : "READY TO FLOW")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(2)
                    .foregroundColor(manager.isRunning ? Theme.Colors.teal : Theme.Colors.textTertiary)
                    .padding(.top, 20)
                    .animation(.easeOut(duration: 0.5), value: manager.isRunning)

                // Main Timer with Glow Effect
                ZStack {
                    // Glow effect when running
                    if manager.isRunning {
                        Circle()
                            .fill(Theme.Colors.teal.opacity(0.05))
                            .frame(width: 192, height: 192)
                            .blur(radius: 48)
                            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: manager.isRunning)
                    }

                    Text(manager.timeFormatted)
                        .font(Theme.Fonts.mono(72))
                        .tracking(-4)
                        .foregroundColor(.white)
                        .contentTransition(.numericText())
                }
                .frame(height: 120)

                // Main Action Buttons
                if manager.isRunning {
                    HStack(spacing: 12) {
                        // Pause Button
                        Button(action: { manager.toggleTimer() }) {
                            HStack(spacing: 8) {
                                Image(systemName: "pause.fill")
                                    .font(.system(size: 16))
                                Text("Pause")
                                    .font(.system(size: 14, weight: .semibold))
                                    .tracking(0.5)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.1))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                            .contentShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)

                        // Stop Button
                        Button(action: { manager.stopTimer() }) {
                            HStack(spacing: 8) {
                                Image(systemName: "stop.fill")
                                    .font(.system(size: 16))
                                Text("Stop")
                                    .font(.system(size: 14, weight: .semibold))
                                    .tracking(0.5)
                            }
                            .foregroundColor(.white.opacity(0.7))
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.05))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                            .contentShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                    }
                    .transition(.opacity)
                } else {
                    // Start Button
                    Button(action: { manager.toggleTimer() }) {
                        HStack(spacing: 8) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 16))
                            Text("Start Focus")
                                .font(.system(size: 14, weight: .semibold))
                                .tracking(0.5)
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Theme.Colors.teal)
                        )
                        .shadow(color: Theme.Colors.teal.opacity(0.2), radius: 8)
                        .contentShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                    .transition(.opacity)
                }

                // Volume Slider
                VolumeSlider(volume: $manager.volume)
                    .padding(.top, 8)
            }
            .padding(.horizontal, 24)

            // Soundscapes Section
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("SOUNDSCAPE")
                        .font(.system(size: 10, weight: .medium))
                        .tracking(1.5)
                        .foregroundColor(Theme.Colors.textSecondary)
                    Spacer()
                    Image(systemName: "ellipsis")
                        .font(.system(size: 14))
                        .foregroundColor(Theme.Colors.textTertiary)
                }

                HStack(spacing: 12) {
                    ForEach(OrbitManager.Soundscape.allCases, id: \.self) { sound in
                        SoundButton(
                            type: sound,
                            isSelected: manager.activeSoundscape == sound,
                            action: { manager.activeSoundscape = sound }
                        )
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 16)
            .background(
                Rectangle()
                    .fill(Color.clear)
                    .overlay(
                        Rectangle()
                            .fill(Color.white.opacity(0.05))
                            .frame(height: 1),
                        alignment: .top
                    )
            )

            Spacer()

            // Footer - Bio Rhythm
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            .frame(width: 20, height: 20)
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 10))
                            .foregroundColor(Color.white.opacity(0.6))
                    }
                    Text("Afternoon Energy Decay")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.9))
                }

                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 4) {
                            Text("Recharge in")
                                .font(.system(size: 10))
                                .foregroundColor(Theme.Colors.textTertiary)
                            Text("27m")
                                .font(.system(size: 10))
                                .foregroundColor(Theme.Colors.teal)
                        }
                        HStack(spacing: 4) {
                            Text("Peak focus")
                                .font(.system(size: 10))
                                .foregroundColor(Theme.Colors.textTertiary)
                            Text("1h 17m")
                                .font(.system(size: 10))
                                .foregroundColor(Color.white.opacity(0.6))
                        }
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Vancouver")
                            .font(.system(size: 10))
                            .foregroundColor(Color.white.opacity(0.6))
                        Text("Rain • Sunset 17:40")
                            .font(.system(size: 10))
                            .foregroundColor(Theme.Colors.textTertiary)
                    }
                }
            }
            .padding(16)
            .background(Theme.Colors.darkPanel)
            .cornerRadius(12, corners: [.bottomLeft, .bottomRight])
        }
    }
}
