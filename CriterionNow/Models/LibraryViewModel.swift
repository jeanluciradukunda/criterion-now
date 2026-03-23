import SwiftUI
import Combine

@MainActor
class LibraryViewModel: ObservableObject {
    @Published var movies: [LibraryMovie] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedMovie: LibraryMovie?
    @Published var selectedMoviePoster: NSImage?
    @Published var selectedMovieSoundtrack: SoundtrackAlbum?
    @Published var selectedMovieSoundtrackArt: NSImage?
    @Published var isLoadingDetail = false
    @Published var lastUpdated: Date?

    // Collection
    @Published var activeCollection: LibraryMovie?
    @Published var collectionFilms: [LibraryMovie] = []
    @Published var isLoadingCollection = false

    let libraryService = CriterionLibraryService()
    private let tmdbService = TMDBService()
    private let soundtrackService = SoundtrackService()
    private let cache = CacheService.shared
    private let store = LocalStore.shared
    private weak var playerManager: PlayerManager?

    func connectPlayer(_ player: PlayerManager) {
        self.playerManager = player
        libraryService.setSharedWebView(player.webView)
    }

    // MARK: - Load Library (from disk first, scrape only on refresh)

    func loadLibrary() async {
        // Try loading from local store first — instant, no network
        if movies.isEmpty {
            if let stored = await store.loadLibrary() {
                movies = stored.map { LibraryMovie.fromStored($0) }
                lastUpdated = await store.libraryLastUpdated()

                // Load collection films from store too
                for i in movies.indices where movies[i].itemType.isCollection && movies[i].isCollectionLoaded {
                    if let storedCollection = await store.loadCollection(slug: movies[i].slug) {
                        movies[i].collectionFilms = storedCollection.films.map { LibraryMovie.fromStored($0) }
                    }
                }

                if !movies.isEmpty { return } // Got data from disk, no need to scrape
            }
        }

        // No local data — need to scrape (first time only)
        await refreshLibrary()
    }

    /// Explicit refresh — scrapes Criterion, enriches with TMDB, saves to disk
    func refreshLibrary() async {
        // Don't scrape while streaming
        if let player = playerManager, player.mode != .off {
            errorMessage = "Stop streaming first to refresh library"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let rawMovies = try await libraryService.fetchMyList()
            self.movies = rawMovies

            // Diff against stored data — only TMDB-enrich new/changed slugs
            let storedMovies = (await store.loadLibrary())?.map { LibraryMovie.fromStored($0) } ?? []
            let existingBySlug = Dictionary(storedMovies.map { ($0.slug, $0) }, uniquingKeysWith: { first, _ in first })

            var toEnrich: [LibraryMovie] = []
            var preEnriched: [LibraryMovie] = []

            for movie in rawMovies {
                if let existing = existingBySlug[movie.slug],
                   !existing.director.isEmpty || existing.itemType.isCollection {
                    // Already enriched — reuse stored data
                    var reused = movie
                    reused.year = existing.year
                    reused.director = existing.director
                    reused.runtime = existing.runtime
                    reused.overview = existing.overview
                    reused.posterURL = existing.posterURL
                    reused.primaryCountry = existing.primaryCountry
                    reused.productionCountries = existing.productionCountries
                    reused.hasSoundtrack = existing.hasSoundtrack
                    reused.soundtrackSource = existing.soundtrackSource
                    preEnriched.append(reused)
                } else {
                    toEnrich.append(movie)
                }
            }

            // Show pre-enriched immediately
            self.movies = preEnriched + toEnrich

            // Only TMDB-enrich truly new items
            if !toEnrich.isEmpty {
                let newlyEnriched = await enrichMoviesConcurrently(toEnrich, concurrency: 5)
                // Merge back
                var final = preEnriched
                for e in newlyEnriched {
                    if let idx = final.firstIndex(where: { $0.slug == e.slug }) {
                        final[idx] = e
                    } else {
                        final.append(e)
                    }
                }
                // Maintain original order
                self.movies = rawMovies.map { raw in
                    final.first(where: { $0.slug == raw.slug }) ?? raw
                }
            } else {
                self.movies = preEnriched
            }

            self.lastUpdated = Date()

            // Save to disk
            await store.saveLibrary(self.movies.map { $0.toStored() })

        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Enrich (TMDB only, no Criterion scraping)

    private func enrichMoviesConcurrently(_ movies: [LibraryMovie], concurrency: Int) async -> [LibraryMovie] {
        var result = movies

        await withTaskGroup(of: (Int, LibraryMovie).self) { group in
            var running = 0

            for (index, movie) in movies.enumerated() {
                if movie.itemType.isCollection { continue }

                if running >= concurrency {
                    if let completed = await group.next() {
                        result[completed.0] = completed.1
                        self.movies = result
                        running -= 1
                    }
                }

                running += 1
                group.addTask { [tmdbService] in
                    var enriched = movie
                    do {
                        let (detail, posterURL) = try await tmdbService.fetchMovieDetails(title: movie.title)
                        if let detail = detail {
                            let tmdbTitle = detail.title.lowercased()
                            let ourTitle = movie.title.lowercased()
                            if tmdbTitle == ourTitle || tmdbTitle.contains(ourTitle) || ourTitle.contains(tmdbTitle) || Self.levenshteinSimilarity(tmdbTitle, ourTitle) > 0.6 {
                                if let rd = detail.releaseDate, rd.count >= 4 {
                                    enriched.year = String(rd.prefix(4))
                                }
                                if let crew = detail.credits?.crew {
                                    enriched.director = crew.first(where: { $0.job == "Director" })?.name ?? ""
                                }
                                if let rt = detail.runtime, rt > 0 {
                                    enriched.runtime = "\(rt) min"
                                }
                                enriched.overview = detail.overview ?? ""
                                enriched.posterURL = posterURL

                                // Extract production countries
                                if let countries = detail.productionCountries, !countries.isEmpty {
                                    enriched.primaryCountry = countries.first?.name ?? ""
                                    enriched.productionCountries = countries.map { $0.name }
                                }
                            }
                        }
                    } catch {}
                    return (index, enriched)
                }
            }

            for await completed in group {
                result[completed.0] = completed.1
                self.movies = result
            }
        }

        return result
    }

    // MARK: - Selection

    func selectMovie(_ movie: LibraryMovie) {
        selectedMovie = movie
        selectedMoviePoster = nil
        selectedMovieSoundtrack = nil
        selectedMovieSoundtrackArt = nil
        isLoadingDetail = true

        Task {
            if let posterURL = movie.displayImageURL {
                if let cached = await cache.getCachedImage(url: posterURL) {
                    selectedMoviePoster = cached
                } else {
                    do {
                        let (data, _) = try await URLSession.shared.data(from: posterURL)
                        if let img = NSImage(data: data) {
                            selectedMoviePoster = img
                            await cache.cacheImage(url: posterURL, image: img)
                        }
                    } catch {}
                }
            }
            isLoadingDetail = false
        }
    }

    func clearSelection() {
        selectedMovie = nil
        selectedMoviePoster = nil
        selectedMovieSoundtrack = nil
        selectedMovieSoundtrackArt = nil
    }

    // MARK: - Collections (also persisted)

    func loadCollection(_ collection: LibraryMovie) async {
        // Check if already loaded in memory
        if let idx = movies.firstIndex(where: { $0.id == collection.id }),
           movies[idx].isCollectionLoaded {
            activeCollection = movies[idx]
            collectionFilms = movies[idx].collectionFilms
            return
        }

        // Check local store
        if let stored = await store.loadCollection(slug: collection.slug) {
            let films = stored.films.map { LibraryMovie.fromStored($0) }
            if let idx = movies.firstIndex(where: { $0.id == collection.id }) {
                movies[idx].collectionDescription = stored.description
                movies[idx].collectionFilms = films
                movies[idx].isCollectionLoaded = true
            }
            activeCollection = collection
            collectionFilms = films
            return
        }

        // Need to scrape — but not while streaming
        if let player = playerManager, player.mode != .off {
            return
        }

        isLoadingCollection = true
        activeCollection = collection

        do {
            let (description, rawFilms) = try await libraryService.fetchCollectionFilms(slug: collection.slug)
            collectionFilms = rawFilms

            let enriched = await enrichMoviesConcurrently(rawFilms, concurrency: 5)
            collectionFilms = enriched

            // Save to memory + disk
            if let idx = movies.firstIndex(where: { $0.id == collection.id }) {
                movies[idx].collectionDescription = description
                movies[idx].collectionFilms = enriched
                movies[idx].isCollectionLoaded = true
                activeCollection = movies[idx]
            }

            await store.saveCollection(slug: collection.slug, description: description, films: enriched.map { $0.toStored() })
            await store.saveLibrary(movies.map { $0.toStored() })

        } catch {}

        isLoadingCollection = false
    }

    func exitCollection() {
        // Clear collection films first so baseMovies falls back to main library
        collectionFilms = []
        activeCollection = nil
    }

    // MARK: - Helpers

    nonisolated static func levenshteinSimilarity(_ a: String, _ b: String) -> Double {
        let aChars = Array(a)
        let bChars = Array(b)
        let aLen = aChars.count
        let bLen = bChars.count
        if aLen == 0 && bLen == 0 { return 1.0 }
        if aLen == 0 || bLen == 0 { return 0.0 }

        var matrix = [[Int]](repeating: [Int](repeating: 0, count: bLen + 1), count: aLen + 1)
        for i in 0...aLen { matrix[i][0] = i }
        for j in 0...bLen { matrix[0][j] = j }
        for i in 1...aLen {
            for j in 1...bLen {
                let cost = aChars[i - 1] == bChars[j - 1] ? 0 : 1
                matrix[i][j] = min(matrix[i - 1][j] + 1, matrix[i][j - 1] + 1, matrix[i - 1][j - 1] + cost)
            }
        }
        return 1.0 - (Double(matrix[aLen][bLen]) / Double(max(aLen, bLen)))
    }
}
