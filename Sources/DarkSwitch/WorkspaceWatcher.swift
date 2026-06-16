import AppKit

/// Observes NSWorkspace notifications to detect frontmost app changes.
/// Uses event-driven callbacks instead of polling.
final class WorkspaceWatcher {
    var onAppChange: ((String) -> Void)?
    private var observer: NSObjectProtocol?

    func start() {
        observer = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didActivateApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] note in
            guard
                let app = note.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
                let name = app.localizedName,
                name != "DarkSwitch"
            else { return }
            self?.onAppChange?(name)
        }
    }

    func stop() {
        guard let observer else { return }
        NSWorkspace.shared.notificationCenter.removeObserver(observer)
        self.observer = nil
    }
}
