import Foundation

// MARK: - Bio Rhythm Service
/// Service responsible for calculating energy levels based on time of day
final class BioRhythmService: ObservableObject {
    @Published private(set) var energyStatus: String = "Calculating..."

    init() {
        updateBioRhythm()
    }

    func updateBioRhythm() {
        let hour = Calendar.current.component(.hour, from: Date())

        if hour >= 6 && hour < 12 {
            energyStatus = "Morning Peak"
        } else if hour >= 12 && hour < 13 {
            energyStatus = "Midday Transition"
        } else if hour >= 13 && hour < 16 {
            energyStatus = "Afternoon Decay (Low Energy)"
        } else if hour >= 16 && hour < 20 {
            energyStatus = "Evening Recovery"
        } else {
            energyStatus = "Night Mode"
        }
    }

    var currentEnergyLevel: EnergyLevel {
        let hour = Calendar.current.component(.hour, from: Date())

        switch hour {
        case 6..<12:
            return .high
        case 12..<13:
            return .medium
        case 13..<16:
            return .low
        case 16..<20:
            return .medium
        default:
            return .low
        }
    }
}

// MARK: - Energy Level
enum EnergyLevel: String, CaseIterable {
    case high = "High"
    case medium = "Medium"
    case low = "Low"

    var color: String {
        switch self {
        case .high: return "green"
        case .medium: return "amber"
        case .low: return "red"
        }
    }
}
