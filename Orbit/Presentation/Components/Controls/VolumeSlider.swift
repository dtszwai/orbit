import SwiftUI

struct VolumeSlider: View {
    @Binding var volume: Double
    let isMuted: Bool
    let onMuteToggle: () -> Void

    @State private var isHovering = false

    var body: some View {
        HStack(spacing: 12) {
            muteButton
            sliderTrack
        }
        .frame(height: 24)
    }

    private var muteButton: some View {
        Button(action: onMuteToggle) {
            Image(systemName: speakerIcon)
                .font(.system(size: 14))
                .foregroundColor(Theme.Colors.textTertiary)
        }
        .buttonStyle(.plain)
    }

    private var speakerIcon: String {
        if isMuted {
            return "speaker.slash.fill"
        } else if volume > 0.5 {
            return "speaker.wave.2.fill"
        } else if volume > 0 {
            return "speaker.wave.1.fill"
        } else {
            return "speaker.fill"
        }
    }

    private var sliderTrack: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Theme.Colors.mediumPanel)
                    .frame(height: 4)

                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.white.opacity(0.3))
                    .frame(width: geometry.size.width * CGFloat(volume), height: 4)

                if isHovering || volume > 0 {
                    Circle()
                        .fill(.white)
                        .frame(width: 12, height: 12)
                        .shadow(color: .black.opacity(0.3), radius: 2)
                        .offset(x: thumbOffset(in: geometry.size.width))
                        .transition(.opacity)
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let newVolume = min(max(0, value.location.x / geometry.size.width), 1.0)
                        volume = newVolume
                    }
            )
            .onHover { hovering in
                withAnimation(.easeOut(duration: AppConfiguration.Animation.quickDuration)) {
                    isHovering = hovering
                }
            }
        }
        .frame(height: 12)
    }

    private func thumbOffset(in width: CGFloat) -> CGFloat {
        max(0, min(width - 12, width * CGFloat(volume) - 6))
    }
}
