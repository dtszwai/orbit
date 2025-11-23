import SwiftUI
import SwiftData

@main
struct OrbitApp: App {
    @StateObject private var manager = OrbitManager()
    @State private var selectedTab = "controls"
    
    // SwiftData container setup
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            TaskItem.self,
            FocusSession.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        // macOS 13+ MenuBarExtra with Window Style
        MenuBarExtra {
            PopoverContentView(selectedTab: $selectedTab, manager: manager)
                .modelContainer(sharedModelContainer)
                .background(Theme.Colors.background)
        } label: {
            // Micro-Orbit (Menu Bar State)
            HStack {
                Image(systemName: manager.isRunning ? "leaf.fill" : "leaf")
                    .foregroundColor(manager.isRunning ? Theme.Colors.teal : .primary)
                if manager.isRunning {
                    Text(manager.timeFormatted)
                        .font(.monospacedDigit(.body)())
                }
            }
        }
        .menuBarExtraStyle(.window) // Allows rich interactive popover behavior
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About Orbit") {
                    // About action
                }
            }
            CommandGroup(replacing: .appTermination) {
                Button("Quit Orbit") {
                    NSApplication.shared.terminate(nil)
                }
                .keyboardShortcut("q", modifiers: .command)
            }
        }
    }
}

// MARK: - Main Popover Container
struct PopoverContentView: View {
    @Binding var selectedTab: String
    @ObservedObject var manager: OrbitManager
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        VStack(spacing: 0) {
            // Custom Navigation Bar
            HStack(alignment: .center) {
                HStack(spacing: 4) {
                    TabButton(title: "Controls", isSelected: selectedTab == "controls") {
                        selectedTab = "controls"
                    }
                    TabButton(title: "Tasks", isSelected: selectedTab == "tasks") {
                        selectedTab = "tasks"
                    }
                    TabButton(title: "Stats", isSelected: selectedTab == "stats") {
                        selectedTab = "stats"
                    }
                }
                .padding(4)
                .background(Theme.Colors.panel)
                .cornerRadius(8)

                Spacer()

                HStack(spacing: 12) {
                    Menu {
                        Button("Generate Mock Data") {
                            manager.generateMockData()
                        }
                        Button("Clear All Data") {
                            manager.clearAllData()
                        }
                        Divider()
                        Button("About Orbit") {}
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.system(size: 16))
                            .foregroundColor(Theme.Colors.textTertiary)
                    }
                    .menuStyle(.borderlessButton)
                    .menuIndicator(.hidden)
                    .fixedSize()

                    Button(action: {
                        NSApplication.shared.terminate(nil)
                    }) {
                        Image(systemName: "xmark.circle")
                            .font(.system(size: 16))
                            .foregroundColor(Theme.Colors.textTertiary)
                    }
                    .buttonStyle(.plain)
                    .help("Quit Orbit")
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)

            // Content with transition
            ZStack {
                if selectedTab == "controls" {
                    ControlsView(manager: manager)
                        .transition(.asymmetric(
                            insertion: .move(edge: .leading).combined(with: .opacity),
                            removal: .move(edge: .trailing).combined(with: .opacity)
                        ))
                }
                if selectedTab == "tasks" {
                    TasksView(manager: manager)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                }
                if selectedTab == "stats" {
                    StatsView(manager: manager)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(width: Theme.width, height: Theme.height)
        .background(Theme.Colors.background)
        .preferredColorScheme(.dark)
        .onAppear {
            manager.modelContext = modelContext
        }
    }
}