import SwiftUI

struct SoundButton: View {
    let soundscape: Soundscape
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .strokeBorder(
                            isSelected ? soundscape.color : Color.white.opacity(0.1),
                            lineWidth: 1.5
                        )
                        .background(
                            Circle()
                                .fill(isSelected ? soundscape.color.opacity(0.2) : Color.clear)
                        )
                        .frame(width: 56, height: 56)
                        .shadow(color: isSelected ? Color.black.opacity(0.3) : .clear, radius: 15)
                        .scaleEffect(isSelected ? 1.05 : 1.0)

                    Image(systemName: soundscape.icon)
                        .font(.system(size: 24, weight: .regular))
                        .foregroundColor(isSelected ? soundscape.color : .white.opacity(0.3))
                }
                .animation(.easeOut(duration: 0.3), value: isSelected)

                Text(soundscape.label)
                    .font(.system(size: 10, weight: .medium))
                    .tracking(0.5)
                    .foregroundColor(isSelected ? .white : .white.opacity(0.3))
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
