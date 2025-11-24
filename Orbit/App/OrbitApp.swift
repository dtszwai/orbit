import SwiftUI
import SwiftData
import AppKit
import Combine

@main
struct OrbitApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate, NSPopoverDelegate {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var contextMenu: NSMenu!
    private var eventMonitor: Any?

    let container = DependencyContainer()

    lazy var sharedModelContainer: ModelContainer = {
        let schema = Schema([TaskItem.self, FocusSession.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    private var cancellables = Set<AnyCancellable>()

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        setupPopover()
        setupContextMenu()
        setupEventMonitor()
        observeTimerChanges()
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "leaf", accessibilityDescription: "Orbit")
            button.action = #selector(handleClick)
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            button.target = self
        }
    }

    private func setupPopover() {
        popover = NSPopover()
        popover.contentSize = NSSize(width: AppConfiguration.UI.popoverWidth, height: AppConfiguration.UI.popoverHeight)
        popover.behavior = .transient
        popover.delegate = self

        let contentView = MainContentWrapper(container: container)
            .modelContainer(sharedModelContainer)
            .background(Theme.Colors.background)

        popover.contentViewController = NSHostingController(rootView: contentView)
    }

    private func setupContextMenu() {
        contextMenu = NSMenu()
        contextMenu.addItem(NSMenuItem(title: "Quit Orbit", action: #selector(quitApp), keyEquivalent: "q"))
    }

    private func setupEventMonitor() {
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            if let popover = self?.popover, popover.isShown {
                popover.performClose(nil)
            }
        }
    }

    private func observeTimerChanges() {
        container.timerService.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateStatusItemAppearance()
            }
            .store(in: &cancellables)

        updateStatusItemAppearance()
    }

    private func updateStatusItemAppearance() {
        guard let button = statusItem.button else { return }

        let isRunning = container.timerService.isRunning
        let isPaused = container.timerService.isPaused

        if isRunning || isPaused {
            button.image = NSImage(systemSymbolName: "leaf.fill", accessibilityDescription: "Orbit")
            button.title = " \(container.timerService.timeFormatted)"
        } else {
            button.image = NSImage(systemSymbolName: "leaf", accessibilityDescription: "Orbit")
            button.title = ""
        }

        if isRunning {
            button.contentTintColor = NSColor(Theme.Colors.teal)
        } else if isPaused {
            button.contentTintColor = NSColor(Theme.Colors.amber)
        } else {
            button.contentTintColor = nil
        }
    }

    @objc private func handleClick() {
        guard let event = NSApp.currentEvent else { return }

        if event.type == .rightMouseUp {
            showContextMenu()
        } else {
            togglePopover()
        }
    }

    private func togglePopover() {
        guard let button = statusItem.button else { return }

        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    private func showContextMenu() {
        guard let button = statusItem.button else { return }
        statusItem.menu = contextMenu
        button.performClick(nil)
        statusItem.menu = nil
    }

    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
    }

    func applicationWillTerminate(_ notification: Notification) {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }
}

struct MainContentWrapper: View {
    @ObservedObject var container: DependencyContainer
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: MainViewModel

    init(container: DependencyContainer) {
        self.container = container
        self._viewModel = StateObject(wrappedValue: MainViewModel(container: container))
    }

    var body: some View {
        PopoverContentView(viewModel: viewModel)
            .onAppear {
                container.configure(with: modelContext)
            }
    }
}
