import SwiftUI

struct ProgressRing: View {
    let progress: Double
    let isActive: Bool
    let timeFormatted: String

    private let glowSize: CGFloat = 160

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.08), lineWidth: AppConfiguration.UI.progressRingLineWidth)
                .frame(width: AppConfiguration.UI.progressRingSize, height: AppConfiguration.UI.progressRingSize)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    Theme.Colors.teal,
                    style: StrokeStyle(lineWidth: AppConfiguration.UI.progressRingLineWidth, lineCap: .round)
                )
                .frame(width: AppConfiguration.UI.progressRingSize, height: AppConfiguration.UI.progressRingSize)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: AppConfiguration.Animation.slowDuration), value: progress)

            if isActive {
                Circle()
                    .fill(Theme.Colors.teal.opacity(0.08))
                    .frame(width: glowSize, height: glowSize)
                    .blur(radius: 40)
            }

            Text(timeFormatted)
                .font(Theme.Fonts.mono(56))
                .tracking(-3)
                .foregroundColor(.white)
                .contentTransition(.numericText())
        }
        .frame(width: AppConfiguration.UI.progressRingSize, height: AppConfiguration.UI.progressRingSize)
    }
}
