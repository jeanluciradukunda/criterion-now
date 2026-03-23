import Foundation

struct Movie {
    let title: String
    let year: String
    let director: String
    let composer: String
    let runtime: String
    let runtimeMinutes: Int
    let overview: String
    let posterURL: URL?
    let criterionSlug: String
    let nextFilmIn: String
    let minutesRemaining: Int

    /// Progress through the film (0.0 to 1.0)
    var progress: Double {
        guard runtimeMinutes > 0, minutesRemaining >= 0 else { return 0 }
        let elapsed = runtimeMinutes - minutesRemaining
        guard elapsed >= 0 else { return 0 }
        return min(1.0, Double(elapsed) / Double(runtimeMinutes))
    }

    var elapsedText: String {
        guard runtimeMinutes > 0 else { return "" }
        let elapsed = max(0, runtimeMinutes - minutesRemaining)
        return "\(elapsed) of \(runtimeMinutes) min"
    }

    var criterionLiveURL: URL {
        URL(string: "https://www.criterionchannel.com/events/criterion-24-7")!
    }

    var criterionBrowseURL: URL {
        URL(string: "https://www.criterionchannel.com/browse")!
    }

    var letterboxdURL: URL {
        let slug = title
            .lowercased()
            .replacingOccurrences(of: "'", with: "")
            .replacingOccurrences(of: "'", with: "")
            .replacingOccurrences(of: ":", with: "")
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: "&", with: "and")
            .replacingOccurrences(of: " ", with: "-")
            .replacingOccurrences(of: "--", with: "-")
        return URL(string: "https://letterboxd.com/film/\(slug)/")!
    }

    var letterboxdSearchURL: URL {
        let query = title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? title
        return URL(string: "https://letterboxd.com/search/\(query)/")!
    }

    var displayTitle: String {
        year.isEmpty ? title : "\(title) (\(year))"
    }

    var copyText: String {
        displayTitle
    }
}

// MARK: - TMDB API Response Models

struct TMDBSearchResponse: Codable {
    let results: [TMDBSearchResult]
}

struct TMDBSearchResult: Codable {
    let id: Int
    let title: String
    let releaseDate: String?
    let posterPath: String?
    let overview: String?

    enum CodingKeys: String, CodingKey {
        case id, title, overview
        case releaseDate = "release_date"
        case posterPath = "poster_path"
    }
}

struct TMDBMovieDetail: Codable {
    let id: Int
    let title: String
    let releaseDate: String?
    let runtime: Int?
    let posterPath: String?
    let overview: String?
    let credits: TMDBCredits?
    let productionCountries: [TMDBCountry]?

    enum CodingKeys: String, CodingKey {
        case id, title, runtime, overview, credits
        case releaseDate = "release_date"
        case posterPath = "poster_path"
        case productionCountries = "production_countries"
    }
}

struct TMDBCountry: Codable {
    let iso31661: String
    let name: String

    enum CodingKeys: String, CodingKey {
        case iso31661 = "iso_3166_1"
        case name
    }
}

struct TMDBCredits: Codable {
    let crew: [TMDBCrewMember]
}

struct TMDBCrewMember: Codable {
    let name: String
    let job: String
}

// MARK: - Criterion Scraped Data

struct CriterionNowPlaying {
    let title: String
    let slug: String
    let nextFilmIn: String
}
