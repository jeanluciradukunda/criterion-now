import SwiftUI

struct SoundtrackView: View {
    let album: SoundtrackAlbum
    let allAlbums: [SoundtrackAlbum]
    let albumArtwork: NSImage?
    let movieTitle: String
    @ObservedObject var scrobbleManager: ScrobbleManager

    @State private var selectedIndex: Int = 0
    private let soundtrackService = SoundtrackService()

    private var currentAlbum: SoundtrackAlbum {
        guard selectedIndex < allAlbums.count else { return album }
        return allAlbums[selectedIndex]
    }

    private var hasMultiple: Bool { allAlbums.count > 1 }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 10) {
                // Carousel indicator (if multiple results)
                if hasMultiple {
                    carouselHeader
                }

                // Album artwork (swipeable if multiple)
                artworkView
                    .padding(.horizontal, 20)
                    .onChange(of: selectedIndex) { _, _ in
                        artworkIndex = 0
                    }

                // Album info
                albumInfoView

                // Scrobble indicator
                if scrobbleManager.isScrobbling {
                    scrobbleIndicator
                }

                // Track listing or "no tracks" indicator
                if currentAlbum.tracks.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 9))
                        Text("Track listing not available · Found via \(currentAlbum.source.label)")
                            .font(.system(size: 9))
                    }
                    .foregroundStyle(.tertiary)
                    .padding(.horizontal, 20)
                } else {
                    trackListView
                        .padding(.horizontal, 14)
                }

                // Music service buttons
                musicServiceGrid
                    .padding(.horizontal, 20)
                    .padding(.top, 4)
            }
        }
    }

    // MARK: - Carousel Header

    private var carouselHeader: some View {
        HStack(spacing: 8) {
            Button {
                if selectedIndex > 0 { withAnimation { selectedIndex -= 1 } }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(selectedIndex > 0 ? .primary : .quaternary)
            }
            .buttonStyle(.plain)
            .disabled(selectedIndex == 0)

            // Dots
            HStack(spacing: 3) {
                ForEach(0..<allAlbums.count, id: \.self) { i in
                    Circle()
                        .fill(i == selectedIndex ? Color.orange : Color.white.opacity(0.2))
                        .frame(width: i == selectedIndex ? 6 : 4, height: i == selectedIndex ? 6 : 4)
                }
            }

            Button {
                if selectedIndex < allAlbums.count - 1 { withAnimation { selectedIndex += 1 } }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(selectedIndex < allAlbums.count - 1 ? .primary : .quaternary)
            }
            .buttonStyle(.plain)
            .disabled(selectedIndex >= allAlbums.count - 1)

            Spacer()

            Text("\(selectedIndex + 1)/\(allAlbums.count) results")
                .font(.system(size: 8, design: .monospaced))
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 20)
        .gesture(
            DragGesture(minimumDistance: 30)
                .onEnded { value in
                    if value.translation.width < -30, selectedIndex < allAlbums.count - 1 {
                        withAnimation { selectedIndex += 1 }
                    } else if value.translation.width > 30, selectedIndex > 0 {
                        withAnimation { selectedIndex -= 1 }
                    }
                }
        )
    }

    // MARK: - Artwork

    @State private var artworkIndex: Int = 0

    private var safeArtworkIndex: Int {
        let count = currentAlbum.allArtworkURLs.count
        guard count > 0 else { return 0 }
        return min(artworkIndex, count - 1)
    }

    private var artworkView: some View {
        Group {
            if !currentAlbum.allArtworkURLs.isEmpty && currentAlbum.allArtworkURLs.count > 1 {
                // Multiple covers — swipeable gallery
                VStack(spacing: 6) {
                    AsyncImage(url: currentAlbum.allArtworkURLs[safeArtworkIndex]) { phase in
                        if case .success(let img) = phase {
                            img.resizable()
                                .aspectRatio(1, contentMode: .fill)
                                .frame(width: 220, height: 220)
                                .clipped()
                        } else {
                            RoundedRectangle(cornerRadius: 14).fill(.ultraThinMaterial)
                                .frame(width: 220, height: 220)
                                .overlay { ProgressView().scaleEffect(0.8) }
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay {
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(Color.white.opacity(0.1), lineWidth: 0.5)
                    }
                    .shadow(color: .black.opacity(0.3), radius: 12, y: 6)
                    .gesture(
                        DragGesture(minimumDistance: 20)
                            .onEnded { value in
                                let urls = currentAlbum.allArtworkURLs
                                if value.translation.width < -20, artworkIndex < urls.count - 1 {
                                    withAnimation { artworkIndex += 1 }
                                } else if value.translation.width > 20, artworkIndex > 0 {
                                    withAnimation { artworkIndex -= 1 }
                                }
                            }
                    )

                    // Image dots
                    HStack(spacing: 3) {
                        ForEach(0..<currentAlbum.allArtworkURLs.count, id: \.self) { i in
                            Circle()
                                .fill(i == safeArtworkIndex ? AppAccent.current : Color.white.opacity(0.2))
                                .frame(width: i == safeArtworkIndex ? 5 : 3, height: i == safeArtworkIndex ? 5 : 3)
                        }
                    }
                    Text("\(safeArtworkIndex + 1)/\(currentAlbum.allArtworkURLs.count) covers")
                        .font(.system(size: 7, design: .monospaced))
                        .foregroundStyle(.quaternary)
                }
            } else if let artwork = albumArtwork {
                // Single cover
                Image(nsImage: artwork)
                    .resizable()
                    .aspectRatio(1, contentMode: .fill)
                    .frame(width: 220, height: 220)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay {
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(Color.white.opacity(0.1), lineWidth: 0.5)
                    }
                    .shadow(color: .black.opacity(0.3), radius: 12, y: 6)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .frame(height: 220)
                    .overlay {
                        VStack(spacing: 8) {
                            Image(systemName: "music.note")
                                .font(.system(size: 36))
                                .foregroundStyle(.tertiary)
                            Text("No artwork")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
            }
        }
    }

    // MARK: - Album Info

    private var albumInfoView: some View {
        VStack(spacing: 2) {
            Text(currentAlbum.albumName)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .padding(.horizontal, 20)

            Text(currentAlbum.artistName)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.secondary)

            HStack(spacing: 6) {
                if !currentAlbum.tracks.isEmpty {
                    Text("\(currentAlbum.tracks.count) tracks")
                        .font(.system(size: 9))
                }
                Text("via \(currentAlbum.source.label)")
                    .font(.system(size: 8))
                if currentAlbum.confidenceScore > 0 {
                    Text("· \(Int(currentAlbum.confidenceScore))%")
                        .font(.system(size: 8, design: .monospaced))
                }
            }
                .foregroundStyle(.tertiary)
        }
    }

    // MARK: - Scrobble Indicator

    private var scrobbleIndicator: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(.red)
                .frame(width: 5, height: 5)
            Text("Scrobbling")
                .font(.system(size: 8, weight: .bold, design: .monospaced))
            if scrobbleManager.scrobbledCount > 0 {
                Text("· \(scrobbleManager.scrobbledCount)")
                    .font(.system(size: 8, weight: .medium, design: .monospaced))
                    .foregroundStyle(.tertiary)
            }
        }
        .foregroundStyle(.secondary)
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(.ultraThinMaterial, in: Capsule())
    }

    // MARK: - Track List

    private var trackListView: some View {
        VStack(spacing: 1) {
            ForEach(Array(currentAlbum.tracks.enumerated()), id: \.element.trackNumber) { index, track in
                trackRow(track: track, index: index)
            }
        }
    }

    private func trackRow(track: SoundtrackTrack, index: Int) -> some View {
        let isCurrent = index == scrobbleManager.currentTrackIndex

        return HStack(spacing: 6) {
            if isCurrent {
                Image(systemName: "speaker.wave.2.fill")
                    .font(.system(size: 8))
                    .foregroundStyle(.orange)
                    .frame(width: 18, alignment: .trailing)
            } else {
                Text("\(track.trackNumber)")
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundStyle(.tertiary)
                    .frame(width: 18, alignment: .trailing)
            }

            Text(track.name)
                .font(.system(size: 10, weight: isCurrent ? .semibold : .regular))
                .foregroundStyle(isCurrent ? .orange : .primary)
                .lineLimit(1)

            Spacer()

            Text(track.durationFormatted)
                .font(.system(size: 9, design: .monospaced))
                .foregroundStyle(isCurrent ? AnyShapeStyle(.orange.opacity(0.7)) : AnyShapeStyle(.tertiary))
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background {
            if isCurrent {
                RoundedRectangle(cornerRadius: 6)
                    .fill(.orange.opacity(0.1))
                    .overlay {
                        RoundedRectangle(cornerRadius: 6)
                            .strokeBorder(.orange.opacity(0.2), lineWidth: 0.5)
                    }
            }
        }
    }

    // MARK: - Music Service Buttons

    private var musicServiceGrid: some View {
        VStack(spacing: 5) {
            HStack(spacing: 5) {
                // Primary source button based on where we found the soundtrack
                if currentAlbum.source == .wikidata, let url = currentAlbum.musicbrainzURL {
                    ActionButton(icon: "globe", label: "Wikidata", color: .blue) {
                        NSWorkspace.shared.open(url)
                    }
                } else if currentAlbum.source == .musicbrainz, let url = currentAlbum.musicbrainzURL {
                    ActionButton(icon: "music.note.list", label: "MusicBrainz", color: .purple) {
                        NSWorkspace.shared.open(url)
                    }
                } else if currentAlbum.source == .discogs, let url = currentAlbum.musicbrainzURL {
                    ActionButton(icon: "opticaldisc.fill", label: "Discogs", color: .orange) {
                        NSWorkspace.shared.open(url)
                    }
                } else if currentAlbum.source == .apple, let url = currentAlbum.appleMusicURL {
                    ActionButton(icon: "applelogo", label: "Apple Music", color: .pink) {
                        NSWorkspace.shared.open(url)
                    }
                } else if currentAlbum.source == .lastfm, let url = currentAlbum.lastfmURL {
                    ActionButton(icon: "music.note.tv", label: "Last.fm", color: .red) {
                        NSWorkspace.shared.open(url)
                    }
                }

                ActionButton(icon: "waveform.circle.fill", label: "Spotify", color: .green) {
                    Task {
                        let url = await soundtrackService.spotifySearchURL(movieTitle: movieTitle)
                        NSWorkspace.shared.open(url)
                    }
                }
            }

            HStack(spacing: 5) {
                ActionButton(icon: "play.rectangle.fill", label: "YouTube Music", color: .red) {
                    Task {
                        let url = await soundtrackService.youTubeMusicSearchURL(movieTitle: movieTitle)
                        NSWorkspace.shared.open(url)
                    }
                }

                ActionButton(icon: "music.note.tv", label: "Last.fm", color: .red.opacity(0.8)) {
                    Task {
                        let lastFM = LastFMService()
                        if let url = await lastFM.profileURL {
                            NSWorkspace.shared.open(url)
                        } else {
                            NSWorkspace.shared.open(URL(string: "https://www.last.fm")!)
                        }
                    }
                }
            }
        }
    }
}
