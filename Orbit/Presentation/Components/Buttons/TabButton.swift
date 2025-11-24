import SwiftUI

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .padding(.vertical, 6)
                .padding(.horizontal, 12)
                .background(backgroundColor)
                .foregroundColor(foregroundColor)
                .cornerRadius(6)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeOut(duration: AppConfiguration.Animation.quickDuration)) {
                isHovered = hovering
            }
        }
        .animation(.easeOut(duration: AppConfiguration.Animation.standardDuration), value: isSelected)
    }

    private var backgroundColor: Color {
        if isSelected {
            return Theme.Colors.mediumPanel
        } else if isHovered {
            return Color.white.opacity(0.05)
        } else {
            return Color.clear
        }
    }

    private var foregroundColor: Color {
        if isSelected {
            return .white
        } else if isHovered {
            return Theme.Colors.textSecondary
        } else {
            return Theme.Colors.textTertiary
        }
    }
}
