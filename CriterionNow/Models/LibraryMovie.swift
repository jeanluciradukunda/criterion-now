import Foundation

enum LibraryItemType: String {
    case movie = "movie"
    case video = "video"
    case collection = "series" // Criterion collections like "Directed by..."

    var label: String {
        switch self {
        case .movie: return "Film"
        case .video: return "Video"
        case .collection: return "Collection"
        }
    }

    var isCollection: Bool { self == .collection }
}

struct LibraryMovie: Identifiable, Hashable {
    let id: String // Criterion slug
    let title: String
    let slug: String
    let criterionURL: URL
    let imageURL: URL? // Criterion's own thumbnail
    let itemType: LibraryItemType

    // Enriched from TMDB (only for movies/videos, not collections)
    var year: String = ""
    var director: String = ""
    var runtime: String = ""
    var overview: String = ""
    var posterURL: URL?
    var tmdbId: Int?

    // Country (from TMDB production_countries)
    var primaryCountry: String = ""
    var productionCountries: [String] = []

    // Soundtrack
    var hasSoundtrack: Bool = false
    var soundtrackSource: String = ""

    // Collection inner films (only for itemType == .collection)
    var collectionDescription: String = ""
    var collectionFilms: [LibraryMovie] = []
    var isCollectionLoaded: Bool = false

    var displayTitle: String {
        year.isEmpty ? title : "\(title) (\(year))"
    }

    var decadeLabel: String? {
        guard let year = Int(year), year > 1900 else { return nil }
        return "\(year / 10 * 10)s"
    }

    func matchesSearchQuery(_ rawQuery: String) -> Bool {
        let query = rawQuery
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        guard !query.isEmpty else { return true }

        let searchableFields = [
            title,
            director,
            year,
            primaryCountry,
            decadeLabel ?? ""
        ]
            .map { $0.lowercased() }

        return searchableFields.contains { $0.contains(query) }
    }

    /// Best image to show — TMDB poster for films, Criterion thumbnail for collections
    var displayImageURL: URL? {
        if itemType.isCollection {
            return imageURL // Collections use Criterion's own image
        }
        return posterURL ?? imageURL
    }

    var letterboxdURL: URL {
        let slug = title.lowercased()
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

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: LibraryMovie, rhs: LibraryMovie) -> Bool {
        lhs.id == rhs.id
    }
}
