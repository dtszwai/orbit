import SwiftUI

// MARK: - Reusable UI Components

struct SoundButton: View {
    let type: OrbitManager.Soundscape
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .strokeBorder(isSelected ? type.color : Color.white.opacity(0.1), lineWidth: 1.5)
                        .background(
                            Circle()
                                .fill(isSelected ? type.color.opacity(0.2) : Color.clear)
                        )
                        .frame(width: 56, height: 56)
                        .shadow(color: isSelected ? Color.black.opacity(0.3) : .clear, radius: 15)
                        .scaleEffect(isSelected ? 1.05 : 1.0)

                    Image(systemName: type.icon)
                        .font(.system(size: 24, weight: .regular))
                        .foregroundColor(isSelected ? type.color : .white.opacity(0.3))
                }
                .animation(.easeOut(duration: 0.3), value: isSelected)

                Text(type.label)
                    .font(.system(size: 10, weight: .medium))
                    .tracking(0.5)
                    .foregroundColor(isSelected ? .white : .white.opacity(0.3))
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .padding(.vertical, 6)
                .padding(.horizontal, 12)
                .background(isSelected ? Theme.Colors.mediumPanel : Color.clear)
                .foregroundColor(isSelected ? .white : Theme.Colors.textTertiary)
                .cornerRadius(6)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .animation(.easeOut(duration: 0.2), value: isSelected)
    }
}

struct VolumeSlider: View {
    @Binding var volume: Double
    @ObservedObject var manager: OrbitManager
    @State private var isHovering = false

    var body: some View {
        HStack(spacing: 12) {
            Button(action: {
                manager.isMuted.toggle()
                if manager.isMuted {
                    manager.volumeBeforeMute = volume
                    volume = 0
                } else {
                    volume = manager.volumeBeforeMute
                }
            }) {
                Image(systemName: manager.isMuted ? "speaker.slash.fill" : (volume > 0.5 ? "speaker.wave.2.fill" : (volume > 0 ? "speaker.wave.1.fill" : "speaker.fill")))
                    .font(.system(size: 14))
                    .foregroundColor(Theme.Colors.textTertiary)
            }
            .buttonStyle(.plain)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Theme.Colors.mediumPanel)
                        .frame(height: 4)

                    // Progress track
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.white.opacity(0.3))
                        .frame(width: geometry.size.width * CGFloat(volume), height: 4)

                    // Draggable thumb
                    if isHovering || volume > 0 {
                        Circle()
                            .fill(.white)
                            .frame(width: 12, height: 12)
                            .shadow(color: .black.opacity(0.3), radius: 2)
                            .offset(x: max(0, min(geometry.size.width - 12, geometry.size.width * CGFloat(volume) - 6)))
                            .transition(.opacity)
                    }
                }
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let newVolume = min(max(0, value.location.x / geometry.size.width), 1.0)
                            volume = newVolume
                            if manager.isMuted && newVolume > 0 {
                                manager.isMuted = false
                            }
                        }
                )
                .onHover { hovering in
                    withAnimation(.easeOut(duration: 0.15)) {
                        isHovering = hovering
                    }
                }
            }
            .frame(height: 12)
        }
        .frame(height: 24)
    }
}