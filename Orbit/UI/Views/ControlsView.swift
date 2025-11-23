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
                Text(manager.isRunning ? (manager.currentTask?.title.uppercased() ?? "FLOW STATE ACTIVE") : "READY TO FLOW")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(2)
                    .foregroundColor(manager.isRunning ? Theme.Colors.teal : Theme.Colors.textTertiary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
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
                .frame(height: 80)
                .padding(.bottom, 8)

                // Duration Selector (only when not running and not paused)
                // COMMENTED OUT: Duration is fixed at 25 minutes
//                if !manager.isRunning && !manager.isPaused {
//                    HStack(spacing: 8) {
//                        ForEach([15, 25, 45, 60], id: \.self) { duration in
//                            let isSelected = Int(manager.timeLeft) == duration * 60
//                            Button(action: {
//                                withAnimation(.easeOut(duration: 0.2)) {
//                                    manager.setDuration(minutes: duration)
//                                }
//                            }) {
//                                Text("\(duration)m")
//                                    .font(.system(size: 12, weight: .medium))
//                                    .foregroundColor(isSelected ? .black : Color.white.opacity(0.6))
//                                    .frame(maxWidth: .infinity)
//                                    .frame(height: 32)
//                                    .background(
//                                        RoundedRectangle(cornerRadius: 8)
//                                            .fill(isSelected ? Theme.Colors.teal : Color.white.opacity(0.05))
//                                    )
//                                    .overlay(
//                                        RoundedRectangle(cornerRadius: 8)
//                                            .stroke(isSelected ? Color.clear : Color.white.opacity(0.1), lineWidth: 1)
//                                    )
//                            }
//                            .buttonStyle(.plain)
//                        }
//                    }
//                    .transition(.opacity.combined(with: .move(edge: .top)))
//                }

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
                            .foregroundColor(Theme.Colors.amber)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Theme.Colors.amber.opacity(0.1))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Theme.Colors.amber.opacity(0.2), lineWidth: 1)
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
                            .foregroundColor(.red.opacity(0.8))
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.red.opacity(0.1))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.red.opacity(0.15), lineWidth: 1)
                            )
                            .contentShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                    }
                    .transition(.opacity)
                } else {
                    // Start/Resume Button
                    Button(action: { manager.toggleTimer() }) {
                        HStack(spacing: 8) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 16))
                            Text(manager.isPaused ? "Resume" : "Start Focus")
                                .font(.system(size: 14, weight: .semibold))
                                .tracking(0.5)
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(manager.isPaused ? Theme.Colors.amber : Theme.Colors.teal)
                        )
                        .shadow(color: (manager.isPaused ? Theme.Colors.amber : Theme.Colors.teal).opacity(0.2), radius: 8)
                        .contentShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                    .transition(.opacity)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)

            // Soundscapes Section - HIDDEN
//            VStack(alignment: .leading, spacing: 8) {
//                Text("SOUNDSCAPE")
//                    .font(.system(size: 10, weight: .medium))
//                    .tracking(1.5)
//                    .foregroundColor(Theme.Colors.textSecondary)
//
//                HStack(spacing: 12) {
//                    ForEach(OrbitManager.Soundscape.allCases, id: \.self) { sound in
//                        SoundButton(
//                            type: sound,
//                            isSelected: manager.activeSoundscape == sound,
//                            action: { manager.activeSoundscape = sound }
//                        )
//                        .frame(maxWidth: .infinity)
//                    }
//                }
//
//                // Volume Slider
//                VolumeSlider(volume: $manager.volume, manager: manager)
//                    .padding(.top, 2)
//            }
//            .padding(.horizontal, 24)
//            .padding(.top, 16)
//            .padding(.bottom, 16)
//            .background(
//                Rectangle()
//                    .fill(Color.clear)
//                    .overlay(
//                        Rectangle()
//                            .fill(Color.white.opacity(0.05))
//                            .frame(height: 1),
//                        alignment: .top
//                    )
//            )
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }
}
