import AppKit

final class AboutWindowController: NSWindowController {
    static let shared = AboutWindowController()

    private init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 360, height: 280),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "About Dark Switch"
        window.isReleasedWhenClosed = false
        window.center()
        super.init(window: window)
        setupContent()
    }

    required init?(coder: NSCoder) { fatalError() }

    func show() {
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func setupContent() {
        guard let contentView = window?.contentView else { return }

        let stack = NSStackView()
        stack.orientation = .vertical
        stack.alignment = .centerX
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -24)
        ])

        // App icon
        let iconView = NSImageView()
        iconView.image = NSApp.applicationIconImage
        iconView.imageScaling = .scaleProportionallyUpOrDown
        iconView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 80),
            iconView.heightAnchor.constraint(equalToConstant: 80)
        ])
        stack.addArrangedSubview(iconView)
        stack.setCustomSpacing(12, after: iconView)

        // App name
        let nameLabel = label("Dark Switch", size: 18, weight: .bold)
        stack.addArrangedSubview(nameLabel)

        // Version
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let versionLabel = label("Version \(version)", size: 12, weight: .regular)
        versionLabel.textColor = .secondaryLabelColor
        stack.addArrangedSubview(versionLabel)
        stack.setCustomSpacing(16, after: versionLabel)

        // Description
        let descLabel = label(
            "Automatically switch between light and dark mode\nbased on the frontmost application.",
            size: 13,
            weight: .regular
        )
        descLabel.maximumNumberOfLines = 2
        descLabel.alignment = .center
        stack.addArrangedSubview(descLabel)
        stack.setCustomSpacing(20, after: descLabel)

        // Divider
        let divider = NSBox()
        divider.boxType = .separator
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.widthAnchor.constraint(equalToConstant: 280).isActive = true
        stack.addArrangedSubview(divider)
        stack.setCustomSpacing(12, after: divider)

        // Open source notice
        let ossLabel = label("Open source software  —  MIT License", size: 11, weight: .regular)
        ossLabel.textColor = .tertiaryLabelColor
        stack.addArrangedSubview(ossLabel)

        // Copyright
        let copyLabel = label("Copyright \u{00A9} 2026 Preston W", size: 11, weight: .regular)
        copyLabel.textColor = .tertiaryLabelColor
        stack.addArrangedSubview(copyLabel)
    }

    private func label(_ text: String, size: CGFloat, weight: NSFont.Weight) -> NSTextField {
        let field = NSTextField(labelWithString: text)
        field.font = .systemFont(ofSize: size, weight: weight)
        field.alignment = .center
        return field
    }
}
