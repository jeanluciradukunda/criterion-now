import XCTest
@testable import Criterion_Now

private final class MemoryStore: SecretStore {
    var items: [String: String] = [:]
    var failWrites = false

    func read(_ account: String) -> String? { items[account] }

    func write(_ account: String, value: String) -> Bool {
        guard !failWrites else { return false }
        items[account] = value
        return true
    }

    func remove(_ account: String) -> Bool {
        items[account] = nil
        return true
    }
}

final class KeychainServiceTests: XCTestCase {
    private var store: MemoryStore!
    private var legacy: UserDefaults!
    private let suite = "KeychainServiceTests"
    private var savedStore: SecretStore!
    private var savedDefaults: UserDefaults!

    override func setUp() {
        savedStore = KeychainService.store
        savedDefaults = KeychainService.legacyDefaults
        store = MemoryStore()
        legacy = UserDefaults(suiteName: suite)
        legacy.removePersistentDomain(forName: suite)
        KeychainService.store = store
        KeychainService.legacyDefaults = legacy
    }

    override func tearDown() {
        legacy.removePersistentDomain(forName: suite)
        KeychainService.store = savedStore
        KeychainService.legacyDefaults = savedDefaults
    }

    func testWritesGoToTheSecretStoreNotPlainDefaults() {
        KeychainService.set(.discogsToken, value: "dummy-token")
        XCTAssertEqual(store.items["discogs_token"], "dummy-token")
        XCTAssertNil(legacy.string(forKey: "cn_secret_discogs_token"))
        XCTAssertEqual(KeychainService.discogsToken, "dummy-token")
    }

    func testMigratesLegacyDefaultsIntoTheStoreAndRemovesThem() {
        legacy.set("dummy-session", forKey: "cn_secret_lastfm_session_key")
        legacy.set("dummy-key", forKey: "cn_secret_tmdb_api_key")
        KeychainService.migrateLegacyDefaults()
        XCTAssertEqual(store.items["lastfm_session_key"], "dummy-session")
        XCTAssertEqual(store.items["tmdb_api_key"], "dummy-key")
        XCTAssertNil(legacy.string(forKey: "cn_secret_lastfm_session_key"))
        XCTAssertNil(legacy.string(forKey: "cn_secret_tmdb_api_key"))
    }

    func testKeepsTheLegacyValueWhenTheStoreWriteFails() {
        legacy.set("dummy-secret", forKey: "cn_secret_lastfm_shared_secret")
        store.failWrites = true
        KeychainService.migrateLegacyDefaults()
        XCTAssertEqual(legacy.string(forKey: "cn_secret_lastfm_shared_secret"), "dummy-secret")
    }

    func testAnExistingStoreValueWinsOverTheLegacyOne() {
        store.items["discogs_token"] = "current"
        legacy.set("stale", forKey: "cn_secret_discogs_token")
        KeychainService.migrateLegacyDefaults()
        XCTAssertEqual(store.items["discogs_token"], "current")
        XCTAssertNil(legacy.string(forKey: "cn_secret_discogs_token"))
    }
}
