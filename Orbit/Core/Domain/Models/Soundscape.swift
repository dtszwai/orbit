import SwiftUI

// MARK: - Soundscape Model
/// Represents the available ambient soundscape options for focus sessions
enum Soundscape: String, CaseIterable, Identifiable {
    case focus = "Zap"
    case natural = "Wind"
    case spatial = "Moon"
    case relax = "Coffee"

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .focus: return Theme.Colors.teal
        case .natural: return Theme.Colors.green
        case .spatial: return Theme.Colors.purple
        case .relax: return Theme.Colors.amber
        }
    }

    var icon: String {
        switch self {
        case .focus: return "bolt.fill"
        case .natural: return "wind"
        case .spatial: return "moon.stars.fill"
        case .relax: return "cup.and.saucer.fill"
        }
    }

    var label: String {
        switch self {
        case .focus: return "Deep Work"
        case .natural: return "Natural"
        case .spatial: return "Spatial"
        case .relax: return "Relax"
        }
    }
}
