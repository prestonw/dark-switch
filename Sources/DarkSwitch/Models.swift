import Foundation

enum AppMode: String, Codable, Equatable {
    case dark = "dark"
    case light = "light"
}

struct Config: Codable {
    var defaultMode: AppMode = .dark
    var appRules: [String: AppMode] = [:]
}
