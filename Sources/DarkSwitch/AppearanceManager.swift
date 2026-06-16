import AppKit

enum AppearanceManager {
    /// Reads current system appearance without Apple Events — no entitlement needed.
    static func current() -> AppMode {
        UserDefaults.standard.string(forKey: "AppleInterfaceStyle") == "Dark" ? .dark : .light
    }

    /// Sets system-wide appearance via NSAppleScript.
    /// Requires the com.apple.security.automation.apple-events entitlement and
    /// NSAppleEventsUsageDescription in Info.plist.
    static func set(_ mode: AppMode) {
        let val = mode == .dark ? "true" : "false"
        let src = "tell application \"System Events\" to tell appearance preferences to set dark mode to \(val)"
        var error: NSDictionary?
        NSAppleScript(source: src)?.executeAndReturnError(&error)
    }
}
