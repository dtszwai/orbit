import SwiftUI
import SwiftData

struct PopoverContentView: View {
    @ObservedObject var viewModel: MainViewModel
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        VStack(spacing: 0) {
            navigationBar
            tabContent
                .animation(.easeOut(duration: AppConfiguration.Animation.quickDuration), value: viewModel.selectedTab)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .frame(width: AppConfiguration.UI.popoverWidth, height: AppConfiguration.UI.popoverHeight)
        .background(Theme.Colors.background)
        .preferredColorScheme(.dark)
        .onAppear {
            viewModel.container.configure(with: modelContext)
        }
    }

    private var navigationBar: some View {
        HStack(alignment: .center) {
            HStack(spacing: 4) {
                ForEach(Tab.allCases, id: \.self) { tab in
                    TabButton(
                        title: tab.title,
                        isSelected: viewModel.selectedTab == tab
                    ) {
                        viewModel.selectedTab = tab
                    }
                }
            }
            .padding(4)
            .background(Theme.Colors.panel)
            .cornerRadius(AppConfiguration.UI.smallCornerRadius)

            Spacer()

            HStack(spacing: 12) {
                settingsMenu
                closeButton
            }
        }
        .padding(.horizontal, AppConfiguration.UI.horizontalPadding)
        .padding(.vertical, AppConfiguration.UI.verticalPadding)
    }

    private var focusModeBinding: Binding<Bool> {
        Binding(
            get: { viewModel.container.focusModeService.isEnabled },
            set: { viewModel.container.focusModeService.isEnabled = $0 }
        )
    }

    private var settingsMenu: some View {
        Menu {
            Toggle("Sync with macOS Focus", isOn: focusModeBinding)

            Divider()

            Button("Generate Mock Data") {
                viewModel.generateMockData()
            }
            Button("Clear All Data") {
                viewModel.clearAllData()
            }
            Divider()
            Button("About Orbit") {}
            Divider()
            Button("Quit Orbit") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q", modifiers: .command)
        } label: {
            Image(systemName: "gearshape")
                .font(.system(size: 16))
                .foregroundColor(Theme.Colors.textTertiary)
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
        .fixedSize()
    }

    private var closeButton: some View {
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

    @ViewBuilder
    private var tabContent: some View {
        switch viewModel.selectedTab {
        case .controls:
            ControlsView(viewModel: viewModel.controlsViewModel)
        case .tasks:
            TasksView(viewModel: viewModel.tasksViewModel)
        case .stats:
            StatsView(viewModel: viewModel.statsViewModel)
        }
    }
}
