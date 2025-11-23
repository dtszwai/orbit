import SwiftUI

// MARK: - Design System
struct Theme {
    static let width: CGFloat = 340
    static let height: CGFloat = 400

    struct Colors {
        static let background = Color(hex: "121212")
        static let panel = Color(hex: "1A1A1A")
        static let darkPanel = Color(hex: "0A0A0A")
        static let mediumPanel = Color(hex: "2A2A2A")
        static let teal = Color(hex: "2DD4BF") // Focus
        static let amber = Color(hex: "F59E0B") // Relax
        static let purple = Color(hex: "C084FC") // Spatial
        static let green = Color(hex: "22C55E") // Natural
        static let textPrimary = Color.white.opacity(0.9)
        static let textSecondary = Color.white.opacity(0.5)
        static let textTertiary = Color.white.opacity(0.3)
    }

    struct Fonts {
        static func mono(_ size: CGFloat, weight: Font.Weight = .light) -> Font {
            .system(size: size, weight: weight, design: .monospaced)
        }

        static func display(_ size: CGFloat, weight: Font.Weight = .semibold) -> Font {
            .system(size: size, weight: weight, design: .rounded)
        }

        static func rounded(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
            .system(size: size, weight: weight, design: .rounded)
        }

        static func body(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
            .system(size: size, weight: weight, design: .default)
        }
    }
}

// Helper for Hex Colors
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}