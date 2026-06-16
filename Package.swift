// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DarkSwitch",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "DarkSwitch",
            path: "Sources/DarkSwitch"
        )
    ]
)
