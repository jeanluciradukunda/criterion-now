import SwiftUI

/// App-wide accent color, driven by the developer setting
struct AppAccent {
    struct Option: Identifiable, Hashable {
        let id: String
        let name: String
        let color: Color

        func hash(into hasher: inout Hasher) { hasher.combine(id) }
        static func == (lhs: Option, rhs: Option) -> Bool { lhs.id == rhs.id }
    }

    static let options: [Option] = [
        Option(id: "orange", name: "Criterion Orange", color: .orange),
        Option(id: "red", name: "Cinema Red", color: Color(red: 0.9, green: 0.2, blue: 0.2)),
        Option(id: "gold", name: "Gold", color: Color(red: 0.85, green: 0.7, blue: 0.3)),
        Option(id: "teal", name: "Teal", color: .teal),
        Option(id: "indigo", name: "Indigo", color: .indigo),
        Option(id: "pink", name: "Rose", color: .pink),
        Option(id: "green", name: "Forest", color: Color(red: 0.3, green: 0.7, blue: 0.4)),
        Option(id: "purple", name: "Purple", color: .purple),
        Option(id: "blue", name: "Blue", color: .blue),
        Option(id: "white", name: "Monochrome", color: Color(white: 0.85)),
    ]

    static func color(for name: String) -> Color {
        options.first(where: { $0.id == name })?.color ?? .orange
    }

    /// Current accent from settings — usable anywhere without environment
    static var current: Color {
        let name = UserDefaults.standard.string(forKey: "accentColorName") ?? "orange"
        return color(for: name)
    }
}

// MARK: - Environment Key

private struct AccentColorKey: EnvironmentKey {
    static let defaultValue: Color = .orange
}

extension EnvironmentValues {
    var appAccent: Color {
        get { self[AccentColorKey.self] }
        set { self[AccentColorKey.self] = newValue }
    }
}
