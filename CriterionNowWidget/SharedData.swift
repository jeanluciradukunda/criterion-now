import Foundation

/// Shared data between main app and widget via UserDefaults suite
struct WidgetSharedData {
    // Using a standard suite name — works without App Groups for dev builds
    static let suiteName = "com.personal.CriterionNow.shared"
    static let defaults = UserDefaults(suiteName: suiteName) ?? .standard

    private enum RetentionPolicy {
        static let maxPosterBytes = 350_000
        static let staleDataAge: TimeInterval = 48 * 60 * 60
    }

    struct Keys {
        static let movieTitle = "widget_movieTitle"
        static let movieYear = "widget_movieYear"
        static let movieDirector = "widget_movieDirector"
        static let movieRuntime = "widget_movieRuntime"
        static let nextFilmIn = "widget_nextFilmIn"
        static let progress = "widget_progress"
        static let posterImageData = "widget_posterData"
        static let lastUpdated = "widget_lastUpdated"
    }

    // MARK: - Write (from main app)

    static func update(
        title: String,
        year: String,
        director: String,
        runtime: String,
        nextFilmIn: String,
        progress: Double,
        posterData: Data?
    ) {
        defaults.set(title, forKey: Keys.movieTitle)
        defaults.set(year, forKey: Keys.movieYear)
        defaults.set(director, forKey: Keys.movieDirector)
        defaults.set(runtime, forKey: Keys.movieRuntime)
        defaults.set(nextFilmIn, forKey: Keys.nextFilmIn)
        defaults.set(progress, forKey: Keys.progress)
        if let posterData, posterData.count <= RetentionPolicy.maxPosterBytes {
            defaults.set(posterData, forKey: Keys.posterImageData)
        } else {
            defaults.removeObject(forKey: Keys.posterImageData)
        }
        defaults.set(Date().timeIntervalSince1970, forKey: Keys.lastUpdated)
    }

    static func clear() {
        [
            Keys.movieTitle,
            Keys.movieYear,
            Keys.movieDirector,
            Keys.movieRuntime,
            Keys.nextFilmIn,
            Keys.progress,
            Keys.posterImageData,
            Keys.lastUpdated,
        ].forEach { defaults.removeObject(forKey: $0) }
    }

    private static func purgeExpiredDataIfNeeded(referenceDate: Date = Date()) {
        let ts = defaults.double(forKey: Keys.lastUpdated)
        guard ts > 0 else { return }

        let updatedAt = Date(timeIntervalSince1970: ts)
        guard referenceDate.timeIntervalSince(updatedAt) > RetentionPolicy.staleDataAge else { return }
        clear()
    }

    // MARK: - Read (from widget)

    static var movieTitle: String {
        purgeExpiredDataIfNeeded()
        return defaults.string(forKey: Keys.movieTitle) ?? ""
    }

    static var movieYear: String {
        purgeExpiredDataIfNeeded()
        return defaults.string(forKey: Keys.movieYear) ?? ""
    }

    static var movieDirector: String {
        purgeExpiredDataIfNeeded()
        return defaults.string(forKey: Keys.movieDirector) ?? ""
    }

    static var movieRuntime: String {
        purgeExpiredDataIfNeeded()
        return defaults.string(forKey: Keys.movieRuntime) ?? ""
    }

    static var nextFilmIn: String {
        purgeExpiredDataIfNeeded()
        return defaults.string(forKey: Keys.nextFilmIn) ?? ""
    }

    static var progress: Double {
        purgeExpiredDataIfNeeded()
        return defaults.double(forKey: Keys.progress)
    }

    static var posterImageData: Data? {
        purgeExpiredDataIfNeeded()
        return defaults.data(forKey: Keys.posterImageData)
    }
    static var lastUpdated: Date? {
        let ts = defaults.double(forKey: Keys.lastUpdated)
        return ts > 0 ? Date(timeIntervalSince1970: ts) : nil
    }

    static var displayTitle: String {
        movieYear.isEmpty ? movieTitle : "\(movieTitle) (\(movieYear))"
    }

    static var hasData: Bool { !movieTitle.isEmpty }
}
