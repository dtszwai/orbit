import Foundation
import SwiftUI

enum AppConfiguration {

    enum Timer {
        static let defaultDuration: TimeInterval = 25 * 60
        static let defaultDurationMinutes: Int = 25
        static let minimumSessionDuration: TimeInterval = 60
        static let availableDurations: [Int] = [15, 25, 45, 60]
        static let tickInterval: TimeInterval = 1.0
    }

    enum UI {
        static let popoverWidth: CGFloat = 340
        static let popoverHeight: CGFloat = 480
        static let progressRingSize: CGFloat = 180
        static let progressRingLineWidth: CGFloat = 4
        static let horizontalPadding: CGFloat = 24
        static let verticalPadding: CGFloat = 16
        static let cornerRadius: CGFloat = 12
        static let smallCornerRadius: CGFloat = 8
    }

    enum Animation {
        static let standardDuration: Double = 0.2
        static let quickDuration: Double = 0.15
        static let slowDuration: Double = 0.5
    }

    enum Audio {
        static let defaultVolume: Double = 0.75
        static let minVolume: Double = 0.0
        static let maxVolume: Double = 1.0
    }

    enum Stats {
        static let daysInWeek: Int = 7
        static let mockDataWeeks: Int = 3
    }
}
