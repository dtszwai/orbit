import Foundation
import SwiftUI

@MainActor
final class MainViewModel: ObservableObject {
    @Published var selectedTab: Tab = .controls

    let container: DependencyContainer

    lazy var controlsViewModel: ControlsViewModel = {
        ControlsViewModel(container: container)
    }()

    lazy var tasksViewModel: TasksViewModel = {
        TasksViewModel(container: container)
    }()

    lazy var statsViewModel: StatsViewModel = {
        StatsViewModel(container: container)
    }()

    init(container: DependencyContainer) {
        self.container = container
    }

    func generateMockData() {
        container.generateMockData()
        statsViewModel.loadStats()
    }

    func clearAllData() {
        container.clearAllData()
        statsViewModel.loadStats()
    }
}

enum Tab: String, CaseIterable {
    case controls = "Controls"
    case tasks = "Tasks"
    case stats = "Stats"

    var title: String { rawValue }
}
