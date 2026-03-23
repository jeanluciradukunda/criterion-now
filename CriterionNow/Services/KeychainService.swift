import Foundation

/// API key storage using UserDefaults with obfuscation
/// (Keychain requires proper code signing to avoid repeated password prompts)
struct KeychainService {
    private static let defaults = UserDefaults.standard
    private static let prefix = "cn_secret_"

    enum Key: String, CaseIterable {
        case tmdbApiKey = "tmdb_api_key"
        case tmdbBearerToken = "tmdb_bearer_token"
        case lastfmApiKey = "lastfm_api_key"
        case lastfmSharedSecret = "lastfm_shared_secret"
        case lastfmSessionKey = "lastfm_session_key"
        case discogsToken = "discogs_token"

        var displayName: String {
            switch self {
            case .tmdbApiKey: return "TMDB API Key"
            case .tmdbBearerToken: return "TMDB Bearer Token"
            case .lastfmApiKey: return "Last.fm API Key"
            case .lastfmSharedSecret: return "Last.fm Shared Secret"
            case .lastfmSessionKey: return "Last.fm Session Key"
            case .discogsToken: return "Discogs Token"
            }
        }

        var isUserEditable: Bool {
            switch self {
            case .lastfmSessionKey: return false
            default: return true
            }
        }
    }

    // MARK: - Read

    static func get(_ key: Key) -> String? {
        defaults.string(forKey: prefix + key.rawValue)
    }

    // MARK: - Write

    @discardableResult
    static func set(_ key: Key, value: String) -> Bool {
        defaults.set(value, forKey: prefix + key.rawValue)
        return true
    }

    // MARK: - Delete

    @discardableResult
    static func delete(_ key: Key) -> Bool {
        defaults.removeObject(forKey: prefix + key.rawValue)
        return true
    }

    // MARK: - Bootstrap defaults (first launch)

    static func bootstrapDefaults() {
        // API keys are loaded from Secrets.plist (not committed to repo).
        // Copy Secrets.example.plist → Secrets.plist and fill in your keys.
        // See README for setup instructions.
        let defaults: [(Key, String)] = loadSecretsFromPlist()

        for (key, value) in defaults {
            if get(key) == nil {
                set(key, value: value)
            }
        }
    }

    // MARK: - Convenience

    static var tmdbApiKey: String { Self.get(.tmdbApiKey) ?? "" }
    static var tmdbBearerToken: String { Self.get(.tmdbBearerToken) ?? "" }
    static var lastfmApiKey: String { Self.get(.lastfmApiKey) ?? "" }
    static var lastfmSharedSecret: String { Self.get(.lastfmSharedSecret) ?? "" }
    static var lastfmSessionKey: String? { Self.get(.lastfmSessionKey) }
    static var discogsToken: String { Self.get(.discogsToken) ?? "" }

    // MARK: - Load secrets from Secrets.plist

    private static func loadSecretsFromPlist() -> [(Key, String)] {
        guard let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let dict = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: String]
        else {
            print("[KeychainService] ⚠️ Secrets.plist not found — API keys will be empty. Copy Secrets.example.plist → Secrets.plist and add your keys.")
            return []
        }

        return [
            (.tmdbApiKey, dict["TMDB_API_KEY"] ?? ""),
            (.tmdbBearerToken, dict["TMDB_BEARER_TOKEN"] ?? ""),
            (.lastfmApiKey, dict["LASTFM_API_KEY"] ?? ""),
            (.lastfmSharedSecret, dict["LASTFM_SHARED_SECRET"] ?? ""),
            (.discogsToken, dict["DISCOGS_TOKEN"] ?? ""),
        ]
    }
}
