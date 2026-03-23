import SwiftUI
import Combine

@MainActor
class ScrobbleManager: ObservableObject {
    @Published var currentTrackIndex: Int = -1
    @Published var isScrobbling: Bool = false
    @Published var scrobbledCount: Int = 0

    private let lastFMService = LastFMService()
    private var timer: Timer?
    private var tracks: [SoundtrackTrack] = []
    private var albumName: String = ""
    private var scaledDurations: [TimeInterval] = []
    private var trackStartTimes: [TimeInterval] = []
    private var filmRuntimeMinutes: Int = 0
    private var lastScrobbledIndex: Int = -1

    private weak var viewModel: NowPlayingViewModel?

    init(viewModel: NowPlayingViewModel) {
        self.viewModel = viewModel
    }

    func configure(album: SoundtrackAlbum, filmRuntimeMinutes: Int) {
        self.tracks = album.tracks
        self.albumName = album.albumName
        self.filmRuntimeMinutes = filmRuntimeMinutes

        let totalAlbumMs = tracks.reduce(0) { $0 + $1.durationMs }
        guard totalAlbumMs > 0, filmRuntimeMinutes > 0 else { return }

        let filmDurationSeconds = Double(filmRuntimeMinutes) * 60.0
        let albumDurationSeconds = Double(totalAlbumMs) / 1000.0
        let scaleFactor = filmDurationSeconds / albumDurationSeconds

        scaledDurations = tracks.map { Double($0.durationMs) / 1000.0 * scaleFactor }
        trackStartTimes = []
        var cumulative: TimeInterval = 0
        for duration in scaledDurations {
            trackStartTimes.append(cumulative)
            cumulative += duration
        }
    }

    func startScrobbling() {
        guard !tracks.isEmpty else { return }
        isScrobbling = true
        lastScrobbledIndex = -1
        scrobbledCount = 0

        checkCurrentTrack()
        timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.checkCurrentTrack()
            }
        }
    }

    func stopScrobbling() {
        isScrobbling = false
        timer?.invalidate()
        timer = nil
        currentTrackIndex = -1
        lastScrobbledIndex = -1
    }

    private func checkCurrentTrack() {
        guard let movie = viewModel?.movie,
              movie.runtimeMinutes > 0,
              !tracks.isEmpty else { return }

        let elapsedMinutes = movie.runtimeMinutes - movie.minutesRemaining
        let elapsedSeconds = Double(max(0, elapsedMinutes)) * 60.0

        let newIndex = trackIndexForElapsedTime(elapsedSeconds)
        guard newIndex >= 0, newIndex < tracks.count else { return }

        let previousIndex = currentTrackIndex
        currentTrackIndex = newIndex

        if newIndex != previousIndex {
            if previousIndex >= 0, previousIndex < tracks.count {
                scrobblePreviousTrack(index: previousIndex)
            }
            updateNowPlaying(index: newIndex)
        }
    }

    private func trackIndexForElapsedTime(_ elapsedSeconds: TimeInterval) -> Int {
        guard !trackStartTimes.isEmpty else { return -1 }
        for i in stride(from: trackStartTimes.count - 1, through: 0, by: -1) {
            if elapsedSeconds >= trackStartTimes[i] {
                return i
            }
        }
        return 0
    }

    private func updateNowPlaying(index: Int) {
        let track = tracks[index]
        let durationSeconds = Int(scaledDurations[index])

        Task {
            do {
                try await lastFMService.updateNowPlaying(
                    artist: track.artistName,
                    track: track.name,
                    album: albumName,
                    duration: durationSeconds
                )
            } catch {
                print("Last.fm now playing error: \(error)")
            }
        }
    }

    private func scrobblePreviousTrack(index: Int) {
        guard index != lastScrobbledIndex else { return }

        let track = tracks[index]
        let scaledDuration = scaledDurations[index]
        let trackDurationSeconds = Double(track.durationMs) / 1000.0
        let minPlayTime = min(30.0, trackDurationSeconds * 0.5)
        guard scaledDuration >= minPlayTime else { return }

        lastScrobbledIndex = index
        let timestamp = Int(Date().timeIntervalSince1970)

        Task {
            do {
                try await lastFMService.scrobble(
                    artist: track.artistName,
                    track: track.name,
                    album: albumName,
                    timestamp: timestamp,
                    duration: Int(trackDurationSeconds)
                )
                scrobbledCount += 1
            } catch {
                print("Last.fm scrobble error: \(error)")
            }
        }
    }
}
