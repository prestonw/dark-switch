import AppKit

final class StatusBarController: NSObject {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let menu = NSMenu()
    private let store = ConfigStore.shared
    private let watcher = WorkspaceWatcher()
    private var frontApp: String = ""
    private var ruleMenuItems: [NSMenuItem] = []

    // Fixed menu items
    private lazy var statusMenuItem: NSMenuItem = {
        let item = NSMenuItem(title: "", action: #selector(toggleDefault), keyEquivalent: "")
        item.target = self
        return item
    }()
    private lazy var toggleMenuItem: NSMenuItem = {
        let item = NSMenuItem(title: "Toggle Default Mode", action: #selector(toggleDefault), keyEquivalent: "")
        item.target = self
        return item
    }()
    private lazy var frontInfoMenuItem: NSMenuItem = {
        let item = NSMenuItem(title: "", action: nil, keyEquivalent: "")
        item.isEnabled = false
        return item
    }()
    private lazy var setLightMenuItem: NSMenuItem = {
        let item = NSMenuItem(title: "  Set Light for this app", action: #selector(setLight), keyEquivalent: "")
        item.target = self
        return item
    }()
    private lazy var setDarkMenuItem: NSMenuItem = {
        let item = NSMenuItem(title: "  Set Dark for this app", action: #selector(setDark), keyEquivalent: "")
        item.target = self
        return item
    }()
    private lazy var clearRuleMenuItem: NSMenuItem = {
        let item = NSMenuItem(title: "  Clear rule for this app", action: #selector(clearRule), keyEquivalent: "")
        item.target = self
        return item
    }()
    private lazy var rulesHeaderMenuItem: NSMenuItem = {
        let item = NSMenuItem(title: "Rules: none", action: nil, keyEquivalent: "")
        item.isEnabled = false
        return item
    }()

    override init() {
        super.init()
        statusItem.menu = menu
        buildMenu()

        watcher.onAppChange = { [weak self] name in
            self?.frontApp = name
            self?.applyMode()
            self?.updateMenu()
        }
        watcher.start()
        applyMode()
        updateMenu()
    }

    // MARK: - Menu construction

    private func buildMenu() {
        menu.addItem(statusMenuItem)
        menu.addItem(toggleMenuItem)
        menu.addItem(.separator())
        menu.addItem(frontInfoMenuItem)
        menu.addItem(setLightMenuItem)
        menu.addItem(setDarkMenuItem)
        menu.addItem(clearRuleMenuItem)
        menu.addItem(.separator())
        menu.addItem(rulesHeaderMenuItem)
        menu.addItem(.separator())
        let about = NSMenuItem(title: "About Dark Switch", action: #selector(showAbout), keyEquivalent: "")
        about.target = self
        menu.addItem(about)
        let quit = NSMenuItem(title: "Quit Dark Switch", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        menu.addItem(quit)
    }

    // MARK: - State

    private func effectiveMode() -> AppMode {
        store.config.appRules[frontApp] ?? store.config.defaultMode
    }

    private func applyMode() {
        AppearanceManager.set(effectiveMode())
    }

    private func updateMenu() {
        let cfg = store.config
        let mode = effectiveMode()
        let hasRule = !frontApp.isEmpty && cfg.appRules[frontApp] != nil

        statusItem.button?.title = mode == .dark ? "●" : "○"

        if hasRule {
            statusMenuItem.title = "Default: \(cfg.defaultMode.rawValue)  |  Active: \(mode.rawValue) (override)"
        } else {
            statusMenuItem.title = "Default: \(cfg.defaultMode.rawValue)  |  Active: \(mode.rawValue)"
        }

        if frontApp.isEmpty {
            frontInfoMenuItem.title = "Front: (unknown)"
            setLightMenuItem.isHidden = true
            setDarkMenuItem.isHidden = true
            clearRuleMenuItem.isHidden = true
        } else {
            if let rule = cfg.appRules[frontApp] {
                frontInfoMenuItem.title = "Front: \(frontApp)  →  \(rule.rawValue)"
                clearRuleMenuItem.isHidden = false
            } else {
                frontInfoMenuItem.title = "Front: \(frontApp)  (no rule)"
                clearRuleMenuItem.isHidden = true
            }
            setLightMenuItem.isHidden = false
            setDarkMenuItem.isHidden = false
        }

        // Rebuild per-app rule items
        ruleMenuItems.forEach { menu.removeItem($0) }
        ruleMenuItems.removeAll()

        let sortedApps = cfg.appRules.keys.sorted()
        if sortedApps.isEmpty {
            rulesHeaderMenuItem.title = "Rules: none"
        } else {
            rulesHeaderMenuItem.title = "Rules (\(sortedApps.count))  —  click to remove"
            let insertAt = menu.index(of: rulesHeaderMenuItem) + 1
            for (offset, appName) in sortedApps.enumerated() {
                let rule = cfg.appRules[appName]!
                let item = NSMenuItem(
                    title: "  \(appName)  →  \(rule.rawValue)",
                    action: #selector(removeRule(_:)),
                    keyEquivalent: ""
                )
                item.target = self
                item.representedObject = appName
                menu.insertItem(item, at: insertAt + offset)
                ruleMenuItems.append(item)
            }
        }
    }

    // MARK: - Actions

    @objc private func toggleDefault() {
        store.config.defaultMode = store.config.defaultMode == .dark ? .light : .dark
        store.save()
        applyMode()
        updateMenu()
    }

    @objc private func setLight() {
        guard !frontApp.isEmpty else { return }
        store.config.appRules[frontApp] = .light
        store.save()
        AppearanceManager.set(.light)
        updateMenu()
    }

    @objc private func setDark() {
        guard !frontApp.isEmpty else { return }
        store.config.appRules[frontApp] = .dark
        store.save()
        AppearanceManager.set(.dark)
        updateMenu()
    }

    @objc private func clearRule() {
        store.config.appRules.removeValue(forKey: frontApp)
        store.save()
        applyMode()
        updateMenu()
    }

    @objc private func showAbout() {
        AboutWindowController.shared.show()
    }

    @objc private func removeRule(_ sender: NSMenuItem) {
        guard let appName = sender.representedObject as? String else { return }
        store.config.appRules.removeValue(forKey: appName)
        store.save()
        applyMode()
        updateMenu()
    }
}
