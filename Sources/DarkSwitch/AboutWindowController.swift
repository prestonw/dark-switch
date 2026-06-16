import AppKit

private let githubURL = URL(string: "https://github.com/prestonw/dark-switch")!
private let licenseURL = URL(string: "https://github.com/prestonw/dark-switch/blob/main/LICENSE")!

final class AboutWindowController: NSWindowController {
    static let shared = AboutWindowController()

    private init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 360, height: 300),
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

        // Clickable app icon → GitHub
        let iconButton = NSButton()
        iconButton.image = NSApp.applicationIconImage
        iconButton.imageScaling = .scaleProportionallyUpOrDown
        iconButton.bezelStyle = .shadowlessSquare
        iconButton.isBordered = false
        iconButton.target = self
        iconButton.action = #selector(openGitHub)
        iconButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconButton.widthAnchor.constraint(equalToConstant: 80),
            iconButton.heightAnchor.constraint(equalToConstant: 80)
        ])
        stack.addArrangedSubview(iconButton)
        stack.setCustomSpacing(12, after: iconButton)

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

        // Links row
        let linksRow = NSStackView()
        linksRow.orientation = .horizontal
        linksRow.spacing = 12
        linksRow.addArrangedSubview(linkLabel("View on GitHub", url: githubURL))
        linksRow.addArrangedSubview(separatorLabel())
        linksRow.addArrangedSubview(linkLabel("MIT License", url: licenseURL))
        stack.addArrangedSubview(linksRow)
        stack.setCustomSpacing(6, after: linksRow)

        // Copyright
        let copyLabel = label("Copyright \u{00A9} 2026 Preston W", size: 11, weight: .regular)
        copyLabel.textColor = .tertiaryLabelColor
        stack.addArrangedSubview(copyLabel)
    }

    // MARK: - Helpers

    private func label(_ text: String, size: CGFloat, weight: NSFont.Weight) -> NSTextField {
        let field = NSTextField(labelWithString: text)
        field.font = .systemFont(ofSize: size, weight: weight)
        field.alignment = .center
        return field
    }

    private func linkLabel(_ text: String, url: URL) -> NSTextField {
        let field = NSTextField()
        field.isEditable = false
        field.isBordered = false
        field.backgroundColor = .clear
        field.isSelectable = true
        field.allowsEditingTextAttributes = true
        field.alignment = .center

        let str = NSMutableAttributedString(string: text)
        str.addAttributes([
            .link: url,
            .font: NSFont.systemFont(ofSize: 11)
        ], range: NSRange(location: 0, length: str.length))
        field.attributedStringValue = str
        return field
    }

    private func separatorLabel() -> NSTextField {
        let f = NSTextField(labelWithString: "·")
        f.font = .systemFont(ofSize: 11)
        f.textColor = .tertiaryLabelColor
        return f
    }

    @objc private func openGitHub() {
        NSWorkspace.shared.open(githubURL)
    }
}
