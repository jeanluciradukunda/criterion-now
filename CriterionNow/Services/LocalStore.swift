import Foundation

/// Persistent local JSON store — saves library data to disk so we never need to re-scrape
/// unless the user explicitly hits refresh
actor LocalStore {
    static let shared = LocalStore()

    private let fileManager = FileManager.default
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private var storeDirectory: URL {
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = appSupport.appendingPathComponent("CriterionNow", isDirectory: true)
        try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    private var libraryFile: URL { storeDirectory.appendingPathComponent("library.json") }
    private var collectionsFile: URL { storeDirectory.appendingPathComponent("collections.json") }
    private var metadataFile: URL { storeDirectory.appendingPathComponent("metadata.json") }

    // MARK: - Library (My List)

    func saveLibrary(_ movies: [StoredMovie]) {
        let data = try? encoder.encode(movies)
        try? data?.write(to: libraryFile, options: .atomic)
        pruneCollections(for: movies)
        saveMetadata(key: "library_date", value: ISO8601DateFormatter().string(from: Date()))
    }

    func loadLibrary() -> [StoredMovie]? {
        guard let data = try? Data(contentsOf: libraryFile) else { return nil }
        return try? decoder.decode([StoredMovie].self, from: data)
    }

    func libraryLastUpdated() -> Date? {
        guard let dateStr = loadMetadata(key: "library_date") else { return nil }
        return ISO8601DateFormatter().date(from: dateStr)
    }

    // MARK: - Collections

    func saveCollection(slug: String, description: String, films: [StoredMovie]) {
        var collections = loadAllCollections()
        collections[slug] = StoredCollection(description: description, films: films, date: Date())
        let data = try? encoder.encode(collections)
        try? data?.write(to: collectionsFile, options: .atomic)
    }

    func loadCollection(slug: String) -> StoredCollection? {
        let collections = loadAllCollections()
        return collections[slug]
    }

    private func loadAllCollections() -> [String: StoredCollection] {
        guard let data = try? Data(contentsOf: collectionsFile) else { return [:] }
        return (try? decoder.decode([String: StoredCollection].self, from: data)) ?? [:]
    }

    // MARK: - Metadata

    private func saveMetadata(key: String, value: String) {
        var meta = loadAllMetadata()
        meta[key] = value
        let data = try? encoder.encode(meta)
        try? data?.write(to: metadataFile, options: .atomic)
    }

    private func loadMetadata(key: String) -> String? {
        loadAllMetadata()[key]
    }

    private func loadAllMetadata() -> [String: String] {
        guard let data = try? Data(contentsOf: metadataFile) else { return [:] }
        return (try? decoder.decode([String: String].self, from: data)) ?? [:]
    }

    private func pruneCollections(for movies: [StoredMovie]) {
        let activeCollectionSlugs = Set(
            movies
                .filter { LibraryItemType(rawValue: $0.itemType)?.isCollection == true }
                .map(\.slug)
        )

        guard !activeCollectionSlugs.isEmpty else {
            try? fileManager.removeItem(at: collectionsFile)
            return
        }

        let collections = loadAllCollections()
        let pruned = collections.filter { activeCollectionSlugs.contains($0.key) }
        guard pruned.count != collections.count else { return }

        let data = try? encoder.encode(pruned)
        try? data?.write(to: collectionsFile, options: .atomic)
    }

    // MARK: - Clear

    func clearAll() {
        try? fileManager.removeItem(at: libraryFile)
        try? fileManager.removeItem(at: collectionsFile)
        try? fileManager.removeItem(at: metadataFile)
    }
}

// MARK: - Stored Models (Codable for JSON persistence)

struct StoredMovie: Codable {
    let id: String
    let title: String
    let slug: String
    let criterionURL: String
    let imageURL: String?
    let itemType: String

    // TMDB enrichment
    var year: String
    var director: String
    var runtime: String
    var overview: String
    var posterURL: String?
    var primaryCountry: String
    var productionCountries: [String]

    // Soundtrack
    var hasSoundtrack: Bool
    var soundtrackSource: String

    // Collection data
    var collectionDescription: String
    var collectionFilmSlugs: [String] // References, not full objects
    var isCollectionLoaded: Bool
}

struct StoredCollection: Codable {
    let description: String
    let films: [StoredMovie]
    let date: Date
}

// MARK: - Conversion helpers

extension LibraryMovie {
    func toStored() -> StoredMovie {
        StoredMovie(
            id: id,
            title: title,
            slug: slug,
            criterionURL: criterionURL.absoluteString,
            imageURL: imageURL?.absoluteString,
            itemType: itemType.rawValue,
            year: year,
            director: director,
            runtime: runtime,
            overview: overview,
            posterURL: posterURL?.absoluteString,
            primaryCountry: primaryCountry,
            productionCountries: productionCountries,
            hasSoundtrack: hasSoundtrack,
            soundtrackSource: soundtrackSource,
            collectionDescription: collectionDescription,
            collectionFilmSlugs: collectionFilms.map { $0.slug },
            isCollectionLoaded: isCollectionLoaded
        )
    }

    static func fromStored(_ s: StoredMovie) -> LibraryMovie {
        var movie = LibraryMovie(
            id: s.id,
            title: s.title,
            slug: s.slug,
            criterionURL: URL(string: s.criterionURL) ?? URL(string: "https://www.criterionchannel.com")!,
            imageURL: s.imageURL.flatMap { URL(string: $0) },
            itemType: LibraryItemType(rawValue: s.itemType) ?? .movie
        )
        movie.year = s.year
        movie.director = s.director
        movie.runtime = s.runtime
        movie.overview = s.overview
        movie.posterURL = s.posterURL.flatMap { URL(string: $0) }
        movie.primaryCountry = s.primaryCountry
        movie.productionCountries = s.productionCountries
        movie.hasSoundtrack = s.hasSoundtrack
        movie.soundtrackSource = s.soundtrackSource
        movie.collectionDescription = s.collectionDescription
        movie.isCollectionLoaded = s.isCollectionLoaded
        return movie
    }
}
