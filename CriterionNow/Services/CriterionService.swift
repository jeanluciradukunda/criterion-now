import Foundation

actor CriterionService {
    private let whatsOnURL = URL(string: "https://whatsonnow.criterionchannel.com/")!

    func fetchNowPlaying() async throws -> CriterionNowPlaying {
        let (data, _) = try await URLSession.shared.data(from: whatsOnURL)
        guard let html = String(data: data, encoding: .utf8) else {
            throw CriterionError.invalidResponse
        }
        return try parse(html: html)
    }

    private func parse(html: String) throws -> CriterionNowPlaying {
        // Extract title from <h2 class="whatson__title">...</h2>
        guard let title = extractBetween(html, start: "whatson__title\">", end: "</h2>") else {
            throw CriterionError.parsingFailed
        }

        // Extract slug from the "More" link href
        let slug: String
        if let moreLink = extractBetween(html, start: "whatson__channel-link--more\" href=\"https://www.criterionchannel.com/", end: "\"") {
            slug = moreLink
        } else if let moreLink = extractBetween(html, start: "channel-link--more\">\n", end: "\n") {
            slug = moreLink.trimmingCharacters(in: .whitespaces)
        } else {
            slug = title.lowercased()
                .replacingOccurrences(of: " ", with: "-")
                .replacingOccurrences(of: "'", with: "")
        }

        // Extract "Next film starts in: X minutes"
        // Note: Criterion's HTML has a typo — </snap> instead of </span>
        let nextFilmIn: String
        if let timeText = extractBetween(html, start: "Next film starts in:", end: "</p>"),
           !timeText.contains("now") {
            // Strip tags and whitespace: e.g. ' <span class="...">25 minutes</snap>' → '25 minutes'
            let cleaned = timeText
                .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            nextFilmIn = cleaned
        } else {
            nextFilmIn = ""
        }

        return CriterionNowPlaying(
            title: decodeHTML(title.trimmingCharacters(in: .whitespacesAndNewlines)),
            slug: slug,
            nextFilmIn: nextFilmIn
        )
    }

    private func decodeHTML(_ string: String) -> String {
        string
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&#39;", with: "'")
            .replacingOccurrences(of: "&apos;", with: "'")
            .replacingOccurrences(of: "&#x27;", with: "'")
            .replacingOccurrences(of: "&#038;", with: "&")
    }

    private func extractBetween(_ string: String, start: String, end: String) -> String? {
        guard let startRange = string.range(of: start) else { return nil }
        let afterStart = string[startRange.upperBound...]
        guard let endRange = afterStart.range(of: end) else { return nil }
        return String(afterStart[..<endRange.lowerBound])
    }
}

enum CriterionError: LocalizedError {
    case invalidResponse
    case parsingFailed

    var errorDescription: String? {
        switch self {
        case .invalidResponse: return "Invalid response from Criterion Channel"
        case .parsingFailed: return "Could not parse now playing info"
        }
    }
}
