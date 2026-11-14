import Foundation
import Security

protocol SecretStore {
    func read(_ account: String) -> String?
    @discardableResult func write(_ account: String, value: String) -> Bool
    @discardableResult func remove(_ account: String) -> Bool
}

struct KeychainStore: SecretStore {
    let service: String

    private func query(_ account: String) -> [String: Any] {
        [kSecClass as String: kSecClassGenericPassword,
         kSecAttrService as String: service,
         kSecAttrAccount as String: account]
    }

    func read(_ account: String) -> String? {
        var query = query(account)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        var item: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
              let data = item as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    @discardableResult
    func write(_ account: String, value: String) -> Bool {
        let data = Data(value.utf8)
        let status = SecItemUpdate(query(account) as CFDictionary, [kSecValueData as String: data] as CFDictionary)
        guard status == errSecItemNotFound else { return status == errSecSuccess }
        var query = query(account)
        query[kSecValueData as String] = data
        query[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
        return SecItemAdd(query as CFDictionary, nil) == errSecSuccess
    }

    @discardableResult
    func remove(_ account: String) -> Bool {
        let status = SecItemDelete(query(account) as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
}

/// API credentials and the Last.fm session key, stored in the Keychain.
struct KeychainService {
    static var store: SecretStore = KeychainStore(service: "com.personal.CriterionNow")
    static var legacyDefaults: UserDefaults = .standard
    private static let legacyPrefix = "cn_secret_"

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
        store.read(key.rawValue)
    }

    // MARK: - Write

    @discardableResult
    static func set(_ key: Key, value: String) -> Bool {
        store.write(key.rawValue, value: value)
    }

    // MARK: - Delete

    @discardableResult
    static func delete(_ key: Key) -> Bool {
        store.remove(key.rawValue)
    }

    // MARK: - Migration from plain UserDefaults

    /// Earlier versions kept the credentials in plain UserDefaults. A legacy value is removed
    /// only once the Keychain holds it, so a failed write never loses a credential.
    static func migrateLegacyDefaults() {
        for key in Key.allCases {
            let legacyKey = legacyPrefix + key.rawValue
            guard let value = legacyDefaults.string(forKey: legacyKey) else { continue }
            if get(key) != nil || set(key, value: value) {
                legacyDefaults.removeObject(forKey: legacyKey)
            }
        }
    }

    // MARK: - Bootstrap defaults (first launch)

    static func bootstrapDefaults() {
        migrateLegacyDefaults()

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
