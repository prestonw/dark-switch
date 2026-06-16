import AppKit

/// Draws and animates the menu bar icon as a pie chart transitioning
/// between fully empty (light mode) and fully filled (dark mode).
final class MenuBarIcon {
    private weak var button: NSStatusBarButton?
    private var timer: Timer?
    private var displayedProgress: Double
    private var startProgress: Double
    private var targetProgress: Double
    private let animDuration: Double = 0.4
    private var elapsed: Double = 0

    init(button: NSStatusBarButton, mode: AppMode) {
        self.button = button
        let p = mode == .dark ? 1.0 : 0.0
        displayedProgress = p
        startProgress = p
        targetProgress = p
        button.title = ""
        button.imagePosition = .imageOnly
        button.image = makeImage(progress: p)
        button.imageScaling = .scaleProportionallyUpOrDown
    }

    func transition(to mode: AppMode) {
        let target = mode == .dark ? 1.0 : 0.0
        guard target != targetProgress else { return }
        startProgress = displayedProgress
        targetProgress = target
        elapsed = 0

        timer?.invalidate()
        let t = Timer(timeInterval: 1.0 / 60.0, repeats: true) { [weak self] timer in
            guard let self else { timer.invalidate(); return }
            self.elapsed += 1.0 / 60.0
            let raw = min(self.elapsed / self.animDuration, 1.0)
            // Ease in-out cubic
            let eased = raw < 0.5
                ? 4 * raw * raw * raw
                : 1 - pow(-2 * raw + 2, 3) / 2
            self.displayedProgress = self.startProgress + (self.targetProgress - self.startProgress) * eased
            self.button?.image = self.makeImage(progress: self.displayedProgress)
            if raw >= 1.0 {
                timer.invalidate()
                self.timer = nil
            }
        }
        // .common mode ensures the animation fires while the menu is open
        RunLoop.current.add(t, forMode: .common)
        timer = t
    }

    private func makeImage(progress: Double) -> NSImage {
        let size = NSSize(width: 16, height: 16)
        let image = NSImage(size: size, flipped: false) { rect in
            let inset: CGFloat = 1.0
            let center = NSPoint(x: rect.midX, y: rect.midY)
            let radius = rect.width / 2 - inset

            if progress > 0.005 {
                let pie = NSBezierPath()
                pie.move(to: center)
                pie.appendArc(
                    withCenter: center,
                    radius: radius + 1,
                    startAngle: 90,
                    endAngle: 90 - 360 * CGFloat(progress),
                    clockwise: true
                )
                pie.close()
                NSColor.black.setFill()
                pie.fill()
            }

            let ring = NSBezierPath(ovalIn: rect.insetBy(dx: inset, dy: inset))
            ring.lineWidth = 1.5
            NSColor.black.setStroke()
            ring.stroke()

            return true
        }
        // template = true lets macOS invert the icon on dark menu bars
        image.isTemplate = true
        return image
    }
}
