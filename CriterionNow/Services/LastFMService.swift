import Foundation
import CommonCrypto
import AppKit

actor LastFMService {
    private var apiKey: String { KeychainService.lastfmApiKey }
    private var sharedSecret: String { KeychainService.lastfmSharedSecret }
    private let apiBaseURL = "https://ws.audioscrobbler.com/2.0/"

    private let usernameKey = "lastfm_username"

    enum LastFMError: LocalizedError {
        case authFailed
        case noToken
        case noSession
        case apiError(String)

        var errorDescription: String? {
            switch self {
            case .authFailed: return "Last.fm authentication failed"
            case .noToken: return "Could not obtain Last.fm token"
            case .noSession: return "No Last.fm session"
            case .apiError(let msg): return "Last.fm: \(msg)"
            }
        }
    }

    // MARK: - Auth State

    var isAuthenticated: Bool {
        KeychainService.lastfmSessionKey != nil
    }

    var username: String? {
        UserDefaults.standard.string(forKey: usernameKey)
    }

    private var sessionKey: String? {
        KeychainService.lastfmSessionKey
    }

    // MARK: - Auth Flow

    func authenticate() async throws {
        let tokenParams: [(String, String)] = [
            ("api_key", apiKey),
            ("method", "auth.getToken")
        ]
        let sig = generateSignature(params: tokenParams)

        var components = URLComponents(string: apiBaseURL)!
        components.queryItems = tokenParams.map { URLQueryItem(name: $0.0, value: $0.1) }
        components.queryItems?.append(URLQueryItem(name: "api_sig", value: sig))
        components.queryItems?.append(URLQueryItem(name: "format", value: "json"))

        let (data, _) = try await URLSession.shared.data(from: components.url!)
        let tokenResponse = try JSONDecoder().decode(LastFMTokenResponse.self, from: data)

        guard let token = tokenResponse.token else {
            throw LastFMError.noToken
        }

        let authURL = URL(string: "https://www.last.fm/api/auth/?api_key=\(apiKey)&token=\(token)")!
        await MainActor.run {
            NSWorkspace.shared.open(authURL)
        }

        // Give user time to authorize in browser, then poll
        try await Task.sleep(nanoseconds: 15_000_000_000)
        try await getSession(token: token)
    }

    func getSession(token: String) async throws {
        let params: [(String, String)] = [
            ("api_key", apiKey),
            ("method", "auth.getSession"),
            ("token", token)
        ]
        let sig = generateSignature(params: params)

        var components = URLComponents(string: apiBaseURL)!
        components.queryItems = params.map { URLQueryItem(name: $0.0, value: $0.1) }
        components.queryItems?.append(URLQueryItem(name: "api_sig", value: sig))
        components.queryItems?.append(URLQueryItem(name: "format", value: "json"))

        let (data, _) = try await URLSession.shared.data(from: components.url!)
        let sessionResponse = try JSONDecoder().decode(LastFMSessionResponse.self, from: data)

        guard let session = sessionResponse.session else {
            if let error = sessionResponse.error, let message = sessionResponse.message {
                throw LastFMError.apiError("\(error): \(message)")
            }
            throw LastFMError.authFailed
        }

        KeychainService.set(.lastfmSessionKey, value: session.key)
        UserDefaults.standard.set(session.name, forKey: usernameKey)
    }

    func logout() {
        KeychainService.delete(.lastfmSessionKey)
        UserDefaults.standard.removeObject(forKey: usernameKey)
    }

    // MARK: - Scrobbling

    func updateNowPlaying(artist: String, track: String, album: String, duration: Int) async throws {
        guard let sk = sessionKey else { throw LastFMError.noSession }

        let params: [(String, String)] = [
            ("album", album),
            ("api_key", apiKey),
            ("artist", artist),
            ("duration", String(duration)),
            ("method", "track.updateNowPlaying"),
            ("sk", sk),
            ("track", track)
        ]

        try await postSignedRequest(params: params)
    }

    func scrobble(artist: String, track: String, album: String, timestamp: Int, duration: Int) async throws {
        guard let sk = sessionKey else { throw LastFMError.noSession }

        let params: [(String, String)] = [
            ("album", album),
            ("api_key", apiKey),
            ("artist", artist),
            ("duration", String(duration)),
            ("method", "track.scrobble"),
            ("sk", sk),
            ("timestamp", String(timestamp)),
            ("track", track)
        ]

        try await postSignedRequest(params: params)
    }

    // MARK: - API Helpers

    private func postSignedRequest(params: [(String, String)]) async throws {
        let sig = generateSignature(params: params)

        var bodyComponents = URLComponents()
        bodyComponents.queryItems = params.map { URLQueryItem(name: $0.0, value: $0.1) }
        bodyComponents.queryItems?.append(URLQueryItem(name: "api_sig", value: sig))
        bodyComponents.queryItems?.append(URLQueryItem(name: "format", value: "json"))

        var request = URLRequest(url: URL(string: apiBaseURL)!)
        request.httpMethod = "POST"
        request.httpBody = bodyComponents.query?.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let (data, _) = try await URLSession.shared.data(for: request)

        if let errorResponse = try? JSONDecoder().decode(LastFMErrorResponse.self, from: data),
           let error = errorResponse.error {
            throw LastFMError.apiError("\(error): \(errorResponse.message ?? "Unknown")")
        }
    }

    private func generateSignature(params: [(String, String)]) -> String {
        let sorted = params.sorted { $0.0 < $1.0 }
        var sigString = ""
        for (key, value) in sorted {
            sigString += key + value
        }
        sigString += sharedSecret
        return md5(sigString)
    }

    private func md5(_ string: String) -> String {
        let data = Data(string.utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        data.withUnsafeBytes { buffer in
            _ = CC_MD5(buffer.baseAddress, CC_LONG(data.count), &digest)
        }
        return digest.map { String(format: "%02hhx", $0) }.joined()
    }

    var profileURL: URL? {
        guard let username = username else { return nil }
        return URL(string: "https://www.last.fm/user/\(username)")
    }
}

// MARK: - Response Models

private struct LastFMTokenResponse: Codable {
    let token: String?
}

private struct LastFMSessionResponse: Codable {
    let session: LastFMSession?
    let error: Int?
    let message: String?
}

private struct LastFMSession: Codable {
    let name: String
    let key: String
    let subscriber: Int?
}

private struct LastFMErrorResponse: Codable {
    let error: Int?
    let message: String?
}
