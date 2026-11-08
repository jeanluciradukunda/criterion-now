import Foundation

actor CriterionService {
    func fetchNowPlaying() async throws -> CriterionNowPlaying {
        let (data, response) = try await URLSession.shared.data(from: Movie.liveURL)
        if CriterionGeoBlock.isGeoBlocked(response.url) {
            throw CriterionError.geoBlocked
        }
        guard let html = String(data: data, encoding: .utf8) else {
            throw CriterionError.invalidResponse
        }
        return try Self.nowPlaying(fromLivePage: html, at: Date())
    }

    struct ScheduleEntry: Decodable {
        let startTime: Date
        let endTime: Date
        let episodeTitle: String
        let guid: String
    }

    /// The live page embeds the week's 24/7 schedule in its Next.js flight payload.
    static func nowPlaying(fromLivePage html: String, at date: Date) throws -> CriterionNowPlaying {
        guard let schedule = schedule(fromLivePage: html),
              let current = schedule.first(where: { $0.startTime <= date && date < $0.endTime }) else {
            throw CriterionError.parsingFailed
        }
        let minutesLeft = Int((current.endTime.timeIntervalSince(date) / 60).rounded(.up))
        return CriterionNowPlaying(
            title: current.episodeTitle,
            slug: filmSlug(guid: current.guid, in: html) ?? fallbackSlug(for: current.episodeTitle),
            nextFilmIn: "\(minutesLeft) minutes"
        )
    }

    static func schedule(fromLivePage html: String) -> [ScheduleEntry]? {
        let payload = flightPayload(from: html)
        guard let start = payload.range(of: "\"schedule\":[")?.upperBound,
              let array = balancedArray(in: payload, openingAt: payload.index(before: start)) else { return nil }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode([ScheduleEntry].self, from: Data(array.utf8))
    }

    private static func flightPayload(from html: String) -> String {
        // Possessive quantifiers: the plain form overflows ICU's backtracking stack on the real
        // page's 260 KB literal and silently matches nothing.
        let pattern = #"self\.__next_f\.push\(\[1,("(?:[^"\\]++|\\.)*+")\]\)"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators]) else { return "" }
        let range = NSRange(html.startIndex..., in: html)
        return regex.matches(in: html, range: range).compactMap { match -> String? in
            guard let literal = Range(match.range(at: 1), in: html) else { return nil }
            return try? JSONDecoder().decode(String.self, from: Data(html[literal].utf8))
        }.joined()
    }

    /// Brackets inside JSON strings (film descriptions) must not end the array early.
    private static func balancedArray(in text: String, openingAt open: String.Index) -> String? {
        var depth = 0
        var inString = false
        var escaped = false
        var index = open
        while index < text.endIndex {
            let char = text[index]
            if inString {
                if escaped { escaped = false } else if char == "\\" { escaped = true } else if char == "\"" { inString = false }
            } else if char == "\"" {
                inString = true
            } else if char == "[" {
                depth += 1
            } else if char == "]" {
                depth -= 1
                if depth == 0 { return String(text[open...index]) }
            }
            index = text.index(after: index)
        }
        return nil
    }

    private static func filmSlug(guid: String, in html: String) -> String? {
        guard let start = html.range(of: "href=\"/films/\(guid)/")?.upperBound,
              let end = html[start...].firstIndex(of: "\"") else { return nil }
        return String(html[start..<end])
    }

    private static func fallbackSlug(for title: String) -> String {
        title.lowercased()
            .replacingOccurrences(of: " ", with: "-")
            .replacingOccurrences(of: "'", with: "")
    }
}

enum CriterionError: LocalizedError {
    case invalidResponse
    case parsingFailed
    case geoBlocked
    case emptyLibrary

    var errorDescription: String? {
        switch self {
        case .invalidResponse: return "Invalid response from Criterion Channel"
        case .parsingFailed: return "Could not parse now playing info"
        case .geoBlocked: return "Criterion Channel isn't available in your location. Turn on a system-wide VPN with a US or Canadian exit and try again."
        case .emptyLibrary: return "No films found on My List. The Criterion site may have changed; your saved library was kept."
        }
    }
}
