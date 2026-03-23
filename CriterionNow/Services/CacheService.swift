import AppKit

/// Shared in-memory caches to avoid redundant network requests
actor CacheService {
    static let shared = CacheService()

    // TMDB results cached by title
    private var tmdbCache: [String: (TMDBMovieDetail?, URL?)] = [:]

    // Soundtrack existence cached by title (just the result, not full track data)
    private var soundtrackExistsCache: [String: (exists: Bool, source: String)] = [:]

    // Full soundtrack album cached by title
    private var soundtrackCache: [String: SoundtrackAlbum] = [:]

    // Poster images cached by URL
    private var imageCache: [URL: NSImage] = [:]

    // MARK: - TMDB

    func getCachedTMDB(title: String) -> (TMDBMovieDetail?, URL?)? {
        tmdbCache[title.lowercased()]
    }

    func cacheTMDB(title: String, detail: TMDBMovieDetail?, posterURL: URL?) {
        tmdbCache[title.lowercased()] = (detail, posterURL)
    }

    // MARK: - Soundtrack Exists

    func getCachedSoundtrackExists(title: String) -> (exists: Bool, source: String)? {
        soundtrackExistsCache[title.lowercased()]
    }

    func cacheSoundtrackExists(title: String, exists: Bool, source: String) {
        soundtrackExistsCache[title.lowercased()] = (exists, source)
    }

    // MARK: - Full Soundtrack

    func getCachedSoundtrack(title: String) -> SoundtrackAlbum? {
        soundtrackCache[title.lowercased()]
    }

    func cacheSoundtrack(title: String, album: SoundtrackAlbum) {
        soundtrackCache[title.lowercased()] = album
    }

    // MARK: - Images

    func getCachedImage(url: URL) -> NSImage? {
        imageCache[url]
    }

    func cacheImage(url: URL, image: NSImage) {
        imageCache[url] = image
        // Cap cache at 100 images
        if imageCache.count > 100 {
            let keysToRemove = Array(imageCache.keys.prefix(20))
            for key in keysToRemove { imageCache.removeValue(forKey: key) }
        }
    }
}
