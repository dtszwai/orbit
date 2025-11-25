import Foundation
import Combine

final class FocusModeService: ObservableObject {
    @Published var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: "focusModeEnabled")
        }
    }

    @Published private(set) var isFocusActive: Bool = false

    init() {
        self.isEnabled = UserDefaults.standard.bool(forKey: "focusModeEnabled")
    }

    func activateFocus() {
        guard isEnabled else { return }

        Task {
            await setFocusMode(enabled: true)
        }
    }

    func deactivateFocus() {
        guard isEnabled else { return }

        Task {
            await setFocusMode(enabled: false)
        }
    }

    @MainActor
    private func setFocusMode(enabled: Bool) async {
        let script: String

        if enabled {
            // AppleScript to enable Do Not Disturb via Control Center
            script = """
            tell application "System Events"
                tell its application process "ControlCenter"
                    set focusItem to first menu bar item of menu bar 1 whose description contains "Focus"
                    perform action "AXPress" of focusItem
                    delay 0.5

                    -- Click "Do Not Disturb" in the menu
                    if exists window 1 then
                        click checkbox "Do Not Disturb" of group 1 of window 1
                    end if
                end tell
            end tell
            """
        } else {
            // Turn off Do Not Disturb
            script = """
            tell application "System Events"
                tell its application process "ControlCenter"
                    set focusItem to first menu bar item of menu bar 1 whose description contains "Focus"

                    -- Only click if Focus is active (icon shows active state)
                    perform action "AXPress" of focusItem
                    delay 0.5

                    if exists window 1 then
                        -- Check if DND is on and turn it off
                        set dndCheckbox to checkbox "Do Not Disturb" of group 1 of window 1
                        if value of dndCheckbox is 1 then
                            click dndCheckbox
                        else
                            -- Close menu if DND already off
                            key code 53 -- Escape
                        end if
                    end if
                end tell
            end tell
            """
        }

        runAppleScript(script)
        isFocusActive = enabled
    }

    private func runAppleScript(_ script: String) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        process.arguments = ["-e", script]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            print("Failed to run AppleScript: \(error)")
        }
    }
}
