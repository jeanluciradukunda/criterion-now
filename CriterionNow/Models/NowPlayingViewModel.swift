import SwiftUI
import Combine
import WidgetKit

extension Notification.Name {
    static let sendTestNotification = Notification.Name("sendTestNotification")
}

// MARK: - Cache

struct MovieCache {
    let movie: Movie
    let posterImage: NSImage?
    let expiresAt: Date  // When the next film starts
}

@MainActor
class NowPlayingViewModel: ObservableObject {
    @Published var movie: Movie?
    @Published var posterImage: NSImage?
    @Published var isLoading = false
    @Published var errorMessage: String?

    /// Live progress (0.0-1.0) that ticks every second
    @Published var liveProgress: Double = 0
    @Published var liveElapsedText: String = ""
    @Published var liveRemainingText: String = ""

    private let criterionService = CriterionService()
    private let tmdbService = TMDBService()
    private let notificationService = NotificationService.shared
    private var cache: MovieCache?
    private var lastNotifiedTitle: String = ""
    private var autoRefreshTimer: Timer?
    private var progressTimer: Timer?

    /// When the current movie data was fetched — used to compute wall-clock elapsed time
    private var fetchTimestamp: Date = Date()
    private var fetchedMinutesRemaining: Int = 0

    init() {
        notificationService.requestPermission()
        Task {
            await refresh()
        }
        startAutoRefreshTimer()
        startProgressTicker()

        // Listen for test notification request from settings
        NotificationCenter.default.addObserver(forName: .sendTestNotification, object: nil, queue: .main) { [weak self] _ in
            self?.sendTestNotification()
        }
    }

    /// Auto-refresh when the current film is about to end
    private func startAutoRefreshTimer() {
        autoRefreshTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self = self, let movie = self.movie else { return }
                // If less than 2 minutes remaining, refresh to catch the new film
                if movie.minutesRemaining <= 2 && movie.minutesRemaining > 0 {
                    await self.forceRefresh()
                }
            }
        }
    }

    /// Live progress ticker — updates every second based on wall clock
    private func startProgressTicker() {
        progressTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.tickProgress()
            }
        }
    }

    private func tickProgress() {
        guard let movie = movie, movie.runtimeMinutes > 0 else {
            liveProgress = 0
            liveElapsedText = ""
            liveRemainingText = ""
            return
        }

        // How many seconds have passed since we fetched the data
        let wallElapsed = Date().timeIntervalSince(fetchTimestamp)

        // Remaining at fetch time (in seconds) minus wall clock elapsed
        let remainingAtFetchSec = Double(fetchedMinutesRemaining) * 60.0
        let currentRemainingSec = max(0, remainingAtFetchSec - wallElapsed)
        let totalSec = Double(movie.runtimeMinutes) * 60.0

        let elapsedSec = totalSec - currentRemainingSec
        let progress = min(1.0, max(0, elapsedSec / totalSec))

        liveProgress = progress

        let elapsedMin = Int(elapsedSec) / 60
        let remainingMin = Int(currentRemainingSec) / 60
        let remainingSec = Int(currentRemainingSec) % 60

        liveElapsedText = "\(elapsedMin) of \(movie.runtimeMinutes) min"
        liveRemainingText = remainingMin > 0
            ? "\(remainingMin)m \(remainingSec)s left"
            : "\(remainingSec)s left"
    }

    /// Send notification for a new film
    private func notifyIfNewFilm(_ movie: Movie, posterImage: NSImage?) {
        let settings = SettingsManager.shared
        guard settings.notifyNewFilm else { return }
        guard movie.title != lastNotifiedTitle else { return }
        lastNotifiedTitle = movie.title
        notificationService.sendNewFilmNotification(
            title: movie.title,
            year: movie.year,
            director: movie.director,
            posterImage: posterImage
        )
    }

    /// Send a test notification with the current movie
    private func updateWidgetData(movie: Movie, posterImage: NSImage?) {
        var posterData: Data?
        if let poster = posterImage,
           let tiff = poster.tiffRepresentation,
           let bitmap = NSBitmapImageRep(data: tiff) {
            // Compress to small JPEG for UserDefaults (keep under 1MB)
            posterData = bitmap.representation(using: .jpeg, properties: [.compressionFactor: 0.5])
        }

        WidgetSharedData.update(
            title: movie.title,
            year: movie.year,
            director: movie.director,
            runtime: movie.runtime,
            nextFilmIn: movie.nextFilmIn,
            progress: movie.progress,
            posterData: posterData
        )

        // Tell WidgetKit to refresh
        if #available(macOS 14.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    func sendTestNotification() {
        guard let movie = movie else { return }
        notificationService.sendNewFilmNotification(
            title: movie.title,
            year: movie.year,
            director: movie.director,
            posterImage: posterImage
        )
    }

    func refresh() async {
        // Check cache first
        if let cache = cache, Date() < cache.expiresAt {
            // Cache is still valid — just update the time remaining from Criterion
            // (the "next in X min" countdown changes, but TMDB data doesn't)
            do {
                let nowPlaying = try await criterionService.fetchNowPlaying()

                // Same movie? Just update the countdown
                if nowPlaying.title == cache.movie.title {
                    let minutesRemaining = Self.parseMinutes(from: nowPlaying.nextFilmIn)
                    self.movie = Movie(
                        title: cache.movie.title,
                        year: cache.movie.year,
                        director: cache.movie.director,
                        composer: cache.movie.composer,
                        runtime: cache.movie.runtime,
                        runtimeMinutes: cache.movie.runtimeMinutes,
                        overview: cache.movie.overview,
                        posterURL: cache.movie.posterURL,
                        criterionSlug: cache.movie.criterionSlug,
                        nextFilmIn: nowPlaying.nextFilmIn,
                        minutesRemaining: minutesRemaining
                    )
                    self.posterImage = cache.posterImage
                    self.fetchTimestamp = Date()
                    self.fetchedMinutesRemaining = minutesRemaining
                    return
                }
                // Different movie — cache is stale, fall through to full fetch
            } catch {
                // Network error on lightweight refresh — use cache as-is
                self.movie = cache.movie
                self.posterImage = cache.posterImage
                return
            }
        }

        // Full fetch
        await fullFetch()
    }

    private func fullFetch() async {
        isLoading = true
        errorMessage = nil

        do {
            // 1. Fetch what's on now from Criterion
            let nowPlaying = try await criterionService.fetchNowPlaying()

            // 2. Fetch movie details from TMDB
            let (tmdbDetail, posterURL) = try await tmdbService.fetchMovieDetails(title: nowPlaying.title)

            // 3. Build our Movie model
            let year: String
            if let releaseDate = tmdbDetail?.releaseDate, releaseDate.count >= 4 {
                year = String(releaseDate.prefix(4))
            } else {
                year = ""
            }

            let director: String
            let composer: String
            if let crew = tmdbDetail?.credits?.crew {
                director = crew.first(where: { $0.job == "Director" })?.name ?? ""
                composer = crew.first(where: { $0.job == "Original Music Composer" })?.name
                    ?? crew.first(where: { $0.job == "Music" })?.name ?? ""
            } else {
                director = ""
                composer = ""
            }

            let runtimeMinutes = tmdbDetail?.runtime ?? 0
            let runtime: String
            if runtimeMinutes > 0 {
                runtime = "\(runtimeMinutes) min"
            } else {
                runtime = ""
            }

            let minutesRemaining = Self.parseMinutes(from: nowPlaying.nextFilmIn)

            let movie = Movie(
                title: nowPlaying.title,
                year: year,
                director: director,
                composer: composer,
                runtime: runtime,
                runtimeMinutes: runtimeMinutes,
                overview: tmdbDetail?.overview ?? "",
                posterURL: posterURL,
                criterionSlug: nowPlaying.slug,
                nextFilmIn: nowPlaying.nextFilmIn,
                minutesRemaining: minutesRemaining
            )

            self.movie = movie
            self.fetchTimestamp = Date()
            self.fetchedMinutesRemaining = minutesRemaining

            // 4. Load poster image
            var loadedPoster: NSImage?
            if let posterURL = posterURL {
                let (imageData, _) = try await URLSession.shared.data(from: posterURL)
                loadedPoster = NSImage(data: imageData)
                self.posterImage = loadedPoster
            } else {
                self.posterImage = nil
            }

            // 5. Cache it — expires when the next film starts
            let expiry: Date
            if minutesRemaining > 0 {
                expiry = Date().addingTimeInterval(Double(minutesRemaining) * 60)
            } else {
                // Unknown duration — cache for 10 minutes as a safe default
                expiry = Date().addingTimeInterval(10 * 60)
            }

            self.cache = MovieCache(
                movie: movie,
                posterImage: loadedPoster,
                expiresAt: expiry
            )

            // 6. Notify if this is a new film
            notifyIfNewFilm(movie, posterImage: loadedPoster)

            // 7. Log to history
            Task {
                await HistoryService.shared.logFilm(
                    title: movie.title,
                    year: movie.year,
                    director: movie.director,
                    composer: movie.composer,
                    runtime: movie.runtime,
                    posterURL: movie.posterURL?.absoluteString
                )
            }

            // 8. Update widget shared data
            updateWidgetData(movie: movie, posterImage: loadedPoster)

        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    /// Force a full fetch, bypassing cache (e.g. user explicitly wants fresh data)
    func forceRefresh() async {
        cache = nil
        await fullFetch()
    }

    func copyTitle() {
        guard let movie = movie else { return }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(movie.copyText, forType: .string)
    }

    func openURL(_ url: URL) {
        NSWorkspace.shared.open(url)
    }

    /// Parse "46 minutes", "1 hour, 12 minutes", "2 hours", etc. into total minutes
    static func parseMinutes(from text: String) -> Int {
        let lower = text.lowercased()
        var total = 0

        // Extract hours
        if let hourMatch = lower.range(of: #"(\d+)\s*hour"#, options: .regularExpression) {
            let digits = lower[hourMatch].filter { $0.isNumber }
            total += (Int(digits) ?? 0) * 60
        }

        // Extract minutes
        if let minMatch = lower.range(of: #"(\d+)\s*minute"#, options: .regularExpression) {
            let digits = lower[minMatch].filter { $0.isNumber }
            total += Int(digits) ?? 0
        }

        // Fallback: just grab any number if no "hour"/"minute" keywords
        if total == 0 {
            let digits = lower.filter { $0.isNumber }
            total = Int(digits) ?? 0
        }

        return total
    }
}
