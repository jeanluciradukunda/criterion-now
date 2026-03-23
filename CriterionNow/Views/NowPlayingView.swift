import SwiftUI

enum ViewTab: String, CaseIterable {
    case film = "Film"
    case soundtrack = "Soundtrack"
}

struct NowPlayingView: View {
    @ObservedObject var viewModel: NowPlayingViewModel
    @ObservedObject var player: PlayerManager
    @ObservedObject var settings: SettingsManager
    @State private var isHoveringRefresh = false
    @State private var copied = false
    @State private var selectedTab: ViewTab = .film
    @State private var soundtrackAlbum: SoundtrackAlbum?
    @State private var soundtrackAlbums: [SoundtrackAlbum] = []
    @State private var soundtrackArtwork: NSImage?
    @State private var soundtrackError: String?
    @State private var hasSoundtrack: Bool = false
    @StateObject private var scrobbleManager: ScrobbleManager
    @StateObject private var libraryVM = LibraryViewModel()
    @State private var isLibraryMode = false
    @State private var isHistoryMode = false
    @State private var isGlobeMode = false
    @StateObject private var statsVM = StatisticsViewModel()
    @State private var focusedLibraryMovie: LibraryMovie?
    @State private var libraryCardIndex: Int = 0

    /// The active movie title for soundtrack context — library film if in library mode, otherwise Now Playing
    private var activeMovieTitle: String {
        if isLibraryMode, let movie = focusedLibraryMovie {
            return movie.title
        }
        return viewModel.movie?.title ?? ""
    }

    init(viewModel: NowPlayingViewModel, player: PlayerManager, settings: SettingsManager) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
        self._player = ObservedObject(wrappedValue: player)
        self._settings = ObservedObject(wrappedValue: settings)
        self._scrobbleManager = StateObject(wrappedValue: ScrobbleManager(viewModel: viewModel))
    }

    var body: some View {
        ZStack {
            VisualEffectBackground()

            VStack(spacing: 0) {
                // Top bar
                topBar
                    .padding(.top, 8)
                    .padding(.horizontal, 16)

                if isGlobeMode {
                    // Globe mode — full takeover
                    StatisticsInlineView(statsVM: statsVM, libraryVM: libraryVM, movies: libraryVM.movies)
                } else if isHistoryMode {
                    // History mode — full takeover
                    HistoryView()
                    Spacer(minLength: 6)
                } else {
                // Header — changes based on mode
                if isLibraryMode {
                    libraryHeaderView
                        .padding(.top, 4)
                        .padding(.bottom, 6)
                } else {
                    headerView
                        .padding(.top, 4)
                        .padding(.bottom, 6)
                }

                // Tab switcher — always visible
                tabSwitcher
                    .padding(.horizontal, 20)
                    .padding(.bottom, 6)

                // Content
                switch selectedTab {
                case .film:
                    if isLibraryMode {
                        // Library card browser
                        InlineLibraryView(
                            libraryVM: libraryVM,
                            currentIndex: $libraryCardIndex,
                            onFocusChange: { movie in
                                focusedLibraryMovie = movie
                                // If we're on Soundtrack tab, reload for the new focused film
                                if selectedTab == .soundtrack {
                                    loadSoundtrackForMovie(title: movie.title)
                                }
                            },
                            onSoundtrackTap: { movie in
                                focusedLibraryMovie = movie
                                loadSoundtrackForMovie(title: movie.title)
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedTab = .soundtrack
                                }
                            }
                        )
                        Spacer(minLength: 6)
                    } else {
                        filmContent
                    }
                case .soundtrack:
                    soundtrackContent
                }

                } // end non-history mode

                // Footer
                HStack(spacing: 6) {
                    if isHistoryMode {
                        Text("History")
                            .font(.system(size: 8))
                            .foregroundStyle(.quaternary)
                    } else if isLibraryMode {
                        VStack(alignment: .leading, spacing: 1) {
                            Text("\(libraryVM.movies.count) films")
                                .font(.system(size: 8))
                                .foregroundStyle(.quaternary)
                            if let date = libraryVM.lastUpdated {
                                Text("Updated \(date, style: .relative) ago")
                                    .font(.system(size: 7))
                                    .foregroundStyle(.quaternary)
                            }
                        }
                    } else {
                        tmdbAttribution
                    }
                    Spacer()
                    refreshButton
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 10)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            libraryVM.connectPlayer(player)
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack(spacing: 10) {
            PinButton(isPinned: $settings.pinMenuPopover)
            Spacer()

            // Library button — toggle mode
            Button {
                if settings.libraryInlineMode {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isLibraryMode.toggle()
                        isHistoryMode = false
                        isGlobeMode = false
                        selectedTab = .film
                        if isLibraryMode {
                            if libraryVM.movies.isEmpty {
                                Task { await libraryVM.loadLibrary() }
                            }
                        } else {
                            // Switching back to Now Playing — reload its soundtrack
                            focusedLibraryMovie = nil
                            soundtrackAlbum = nil
                            soundtrackArtwork = nil
                            soundtrackError = nil
                            hasSoundtrack = false
                        }
                    }
                } else {
                    LibraryWindowController.shared.show()
                }
            } label: {
                Image(systemName: "books.vertical")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(isLibraryMode ? AppAccent.current : .secondary)
            }
            .buttonStyle(.plain)
            .help(isLibraryMode ? "Back to Now Playing" : "My Library")

            // History button
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isHistoryMode.toggle()
                    if isHistoryMode {
                        isLibraryMode = false
                        isGlobeMode = false
                    }
                }
            } label: {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(isHistoryMode ? AppAccent.current : .secondary)
            }
            .buttonStyle(.plain)
            .help(isHistoryMode ? "Back to Now Playing" : "Viewing History")

            // Globe / Statistics button
            Button {
                if settings.statisticsInlineMode {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isGlobeMode.toggle()
                        if isGlobeMode {
                            isLibraryMode = false
                            isHistoryMode = false
                            // Always start globe with full library, not a collection subset
                            if libraryVM.activeCollection != nil {
                                libraryVM.exitCollection()
                            }
                        }
                    }
                } else {
                    StatisticsWindowController.shared.show(movies: libraryVM.movies)
                }
            } label: {
                Image(systemName: "globe.americas")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(isGlobeMode ? AppAccent.current : .secondary)
            }
            .buttonStyle(.plain)
            .help(isGlobeMode ? "Back to Now Playing" : "Your Cinema World")

            // Settings button
            Button {
                SettingsWindowController.shared.show()
            } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .help("Settings")

            // Quit button
            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                Image(systemName: "power")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.tertiary)
            }
            .buttonStyle(.plain)
            .help("Quit Criterion Now")
        }
    }

    // MARK: - Library Header

    private var libraryHeaderView: some View {
        VStack(spacing: 2) {
            if let collection = libraryVM.activeCollection {
                Text("COLLECTION")
                    .font(.system(size: 10, weight: .semibold))
                    .tracking(2)
                    .foregroundStyle(AppAccent.current)
                Text(collection.title)
                    .font(.system(size: 12, weight: .bold))
                    .tracking(0.5)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .padding(.horizontal, 20)
            } else {
                Text("MY")
                    .font(.system(size: 10, weight: .semibold))
                    .tracking(2)
                    .foregroundStyle(.secondary)
                Text("LIBRARY")
                    .font(.system(size: 13, weight: .bold))
                    .tracking(1.5)
                    .foregroundStyle(.primary)
            }
        }
    }

    // MARK: - Header

    private var headerView: some View {
        VStack(spacing: 2) {
            Text("NOW ON")
                .font(.system(size: 10, weight: .semibold))
                .tracking(2)
                .foregroundStyle(.secondary)
            Text("CRITERION 24/7")
                .font(.system(size: 13, weight: .bold))
                .tracking(1.5)
                .foregroundStyle(.primary)
        }
    }

    // MARK: - Tab Switcher

    private var tabSwitcher: some View {
        HStack(spacing: 0) {
            ForEach(ViewTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab
                    }
                    if tab == .soundtrack {
                        if isLibraryMode, let movie = focusedLibraryMovie {
                            // Library mode — load soundtrack for focused library film
                            loadSoundtrackForMovie(title: movie.title)
                        } else if soundtrackAlbum == nil && soundtrackError == nil {
                            // Now Playing mode — load for current stream
                            loadSoundtrack()
                        }
                    }
                } label: {
                    Text(tab.rawValue)
                        .font(.system(size: 10, weight: selectedTab == tab ? .bold : .medium))
                        .foregroundStyle(selectedTab == tab ? .white : .secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 5)
                        .background {
                            if selectedTab == tab {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(AppAccent.current.opacity(0.6))
                            }
                        }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(3)
        .background {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.05))
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(Color.white.opacity(0.08), lineWidth: 0.5)
                }
        }
    }

    // MARK: - Film Content

    private var filmContent: some View {
        Group {
            if player.mode != .off && player.dock == .docked {
                dockedPlayerView
                    .padding(.horizontal, player.mode == .video ? 0 : 16)
            } else {
                posterView
                    .padding(.horizontal, 20)
            }

            progressBarView
                .padding(.top, 8)
                .padding(.horizontal, 20)

            movieInfoView
                .padding(.top, 6)
                .padding(.horizontal, 20)

            if player.mode != .off && player.dock == .docked {
                PlayerControlsView(player: player, viewModel: viewModel)
                    .padding(.top, 4)
            }

            Spacer(minLength: 6)

            actionButtonGrid
                .padding(.horizontal, 20)
                .padding(.bottom, 4)
        }
    }

    // MARK: - Soundtrack Content

    private var soundtrackContent: some View {
        Group {
            if let album = soundtrackAlbum {
                SoundtrackView(
                    album: album,
                    allAlbums: soundtrackAlbums,
                    albumArtwork: soundtrackArtwork,
                    movieTitle: activeMovieTitle,
                    scrobbleManager: scrobbleManager
                )
                Spacer(minLength: 6)
            } else if soundtrackError != nil {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 12) {
                        Image("NoSoundtrack")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 200)
                            .opacity(0.6)
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                        Text("No soundtrack found")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.secondary)

                        Text("The agent searched 5 sources but couldn't find a verified match for this film.")
                            .font(.system(size: 9))
                            .foregroundStyle(.tertiary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)

                        Button("Retry") { loadSoundtrack() }
                            .font(.system(size: 10, weight: .medium))
                            .buttonStyle(.plain)
                            .foregroundStyle(AppAccent.current)
                            .padding(.top, 4)

                        Image("NoSoundtrackV2")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 160)
                            .opacity(0.4)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding(.top, 8)
                    }
                    .padding(.top, 8)
                }
                Spacer(minLength: 6)
            } else {
                Spacer()
                ProgressView()
                    .scaleEffect(1.0)
                    .tint(.secondary)
                Text("Loading soundtrack...")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                    .padding(.top, 6)
                Spacer()
            }
        }
    }

    private func loadSoundtrack() {
        soundtrackError = nil
        guard let movie = viewModel.movie else {
            soundtrackError = "No film data available"
            return
        }
        Task {
            let service = SoundtrackService()
            do {
                let albums = try await service.searchSoundtrackAll(
                    movieTitle: movie.title,
                    composer: movie.composer,
                    year: movie.year,
                    director: movie.director
                )
                self.soundtrackAlbums = albums
                self.soundtrackAlbum = albums.first
                self.hasSoundtrack = true

                if let artworkURL = albums.first?.artworkURL {
                    let (data, _) = try await URLSession.shared.data(from: artworkURL)
                    self.soundtrackArtwork = NSImage(data: data)
                }

                if let bestAlbum = albums.first {
                    scrobbleManager.configure(album: bestAlbum, filmRuntimeMinutes: movie.runtimeMinutes)
                }

                let lastFM = LastFMService()
                if await lastFM.isAuthenticated && settings.scrobblingEnabled {
                    scrobbleManager.startScrobbling()
                }
            } catch {
                soundtrackError = error.localizedDescription
            }
        }
    }

    private func loadSoundtrackForMovie(title: String) {
        soundtrackAlbum = nil
        soundtrackArtwork = nil
        soundtrackError = nil
        hasSoundtrack = false

        Task {
            let service = SoundtrackService()
            do {
                let albums = try await service.searchSoundtrackAll(movieTitle: title)
                self.soundtrackAlbums = albums
                self.soundtrackAlbum = albums.first
                self.hasSoundtrack = true
                if let artworkURL = albums.first?.artworkURL {
                    let (data, _) = try await URLSession.shared.data(from: artworkURL)
                    self.soundtrackArtwork = NSImage(data: data)
                }
            } catch {
                soundtrackError = error.localizedDescription
            }
        }
    }

    // MARK: - Poster

    private var posterView: some View {
        Group {
            if viewModel.isLoading {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .frame(height: 380)
                    .overlay {
                        ProgressView().scaleEffect(1.2).tint(.secondary)
                    }
            } else if let posterImage = viewModel.posterImage {
                Image(nsImage: posterImage)
                    .resizable()
                    .aspectRatio(2/3, contentMode: .fit)
                    .frame(maxHeight: 380)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .black.opacity(0.3), radius: 12, y: 6)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .frame(height: 380)
                    .overlay {
                        VStack(spacing: 8) {
                            Image(systemName: "film")
                                .font(.system(size: 40))
                                .foregroundStyle(.tertiary)
                            if let error = viewModel.errorMessage {
                                Text(error)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                        }
                    }
            }
        }
    }

    // MARK: - Docked Player

    @State private var vinylSpinning = false

    private var dockedPlayerView: some View {
        ZStack {
            if player.mode == .radio {
                // Radio mode — spinning vinyl with poster as label
                VStack(spacing: 8) {
                    ZStack {
                        // Vinyl disc base
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color(white: 0.06),
                                        Color(white: 0.14),
                                        Color(white: 0.04),
                                        Color(white: 0.11),
                                        Color(white: 0.06),
                                        Color(white: 0.13),
                                        Color(white: 0.04)
                                    ],
                                    center: .center,
                                    startRadius: 8,
                                    endRadius: 110
                                )
                            )
                            .frame(width: 220, height: 220)
                            .overlay {
                                // Groove lines — concentric rings
                                ForEach([30, 42, 52, 62, 72, 80, 88, 96, 104], id: \.self) { r in
                                    Circle()
                                        .strokeBorder(Color.white.opacity(0.06), lineWidth: 0.5)
                                        .frame(width: CGFloat(r) * 2, height: CGFloat(r) * 2)
                                }
                            }
                            .overlay {
                                // Light reflection streak
                                Ellipse()
                                    .fill(
                                        LinearGradient(
                                            colors: [.clear, .white.opacity(0.06), .clear],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: 200, height: 60)
                                    .rotationEffect(.degrees(-30))
                                    .offset(y: -30)
                            }
                            .rotationEffect(.degrees(vinylSpinning ? 360 : 0))
                            .animation(
                                vinylSpinning
                                    ? .linear(duration: 3).repeatForever(autoreverses: false)
                                    : .default,
                                value: vinylSpinning
                            )

                        // Poster as center label
                        if let posterImage = viewModel.posterImage {
                            Image(nsImage: posterImage)
                                .resizable()
                                .aspectRatio(1, contentMode: .fill)
                                .frame(width: 86, height: 86)
                                .clipShape(Circle())
                                .overlay {
                                    Circle().strokeBorder(Color.white.opacity(0.2), lineWidth: 1.5)
                                }
                                .shadow(color: .black.opacity(0.5), radius: 10, y: 3)
                                .rotationEffect(.degrees(vinylSpinning ? 360 : 0))
                                .animation(
                                    vinylSpinning
                                        ? .linear(duration: 3).repeatForever(autoreverses: false)
                                        : .default,
                                    value: vinylSpinning
                                )
                        } else {
                            // Fallback label when no poster
                            Circle()
                                .fill(AppAccent.current.opacity(0.3))
                                .frame(width: 86, height: 86)
                                .overlay {
                                    Circle().strokeBorder(Color.white.opacity(0.2), lineWidth: 1.5)
                                }
                        }

                        // Center spindle
                        Circle()
                            .fill(Color(white: 0.18))
                            .frame(width: 10, height: 10)
                            .overlay {
                                Circle().strokeBorder(Color.white.opacity(0.1), lineWidth: 0.5)
                            }
                    }
                    .shadow(color: .black.opacity(0.4), radius: 15, y: 5)

                    // Visualizer below the vinyl
                    AudioVisualizerView(barCount: 36, color: AppAccent.current, isPlaying: player.mode == .radio, audioLevels: player.audioLevels)
                        .frame(height: 28)
                        .padding(.horizontal, 16)

                    // Radio badge
                    HStack(spacing: 4) {
                        Circle().fill(.red).frame(width: 5, height: 5)
                        Text("RADIO")
                            .font(.system(size: 7, weight: .bold, design: .monospaced))
                    }
                    .foregroundStyle(.white.opacity(0.8))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(.ultraThinMaterial, in: Capsule())
                }
                .onAppear { vinylSpinning = true }
                .onDisappear { vinylSpinning = false }
                .onChange(of: player.mode) { _, mode in
                    vinylSpinning = (mode == .radio)
                }
            } else {
                // Video mode — edge-to-edge, fills width
                ZStack {
                    Color.black
                    StreamWebView(webView: player.webView)
                    if player.isLoading {
                        ProgressView().scaleEffect(1.2).tint(.white)
                    }
                    // Subtitle toggle
                    VStack {
                        HStack {
                            Spacer()
                            Button {
                                player.toggleSubtitles()
                            } label: {
                                Image(systemName: player.subtitlesEnabled ? "captions.bubble.fill" : "captions.bubble")
                                    .font(.system(size: 10))
                                    .foregroundStyle(player.subtitlesEnabled ? AppAccent.current : .white.opacity(0.5))
                                    .padding(5)
                                    .background(.ultraThinMaterial, in: Circle())
                            }
                            .buttonStyle(.plain)
                            .padding(8)
                        }
                        Spacer()
                    }
                }
                .aspectRatio(16/9, contentMode: .fit)
            }
        }
    }

    // MARK: - Progress Bar

    private var progressBarView: some View {
        Group {
            if viewModel.movie != nil, viewModel.liveProgress > 0 || viewModel.movie?.runtimeMinutes ?? 0 > 0 {
                VStack(spacing: 4) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3).fill(Color.white.opacity(0.1))
                            RoundedRectangle(cornerRadius: 3)
                                .fill(LinearGradient(colors: [.red.opacity(0.8), AppAccent.current.opacity(0.9)], startPoint: .leading, endPoint: .trailing))
                                .frame(width: geo.size.width * viewModel.liveProgress)
                                .animation(.linear(duration: 1), value: viewModel.liveProgress)
                        }
                    }
                    .frame(height: 5)
                    HStack {
                        Text(viewModel.liveElapsedText)
                            .font(.system(size: 9, weight: .medium, design: .monospaced))
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(viewModel.liveRemainingText)
                            .font(.system(size: 9, weight: .medium, design: .monospaced))
                            .foregroundStyle(.tertiary)
                        Text("\(Int(viewModel.liveProgress * 100))%")
                            .font(.system(size: 9, weight: .semibold, design: .monospaced))
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    // MARK: - Movie Info

    private var movieInfoView: some View {
        VStack(spacing: 3) {
            if let movie = viewModel.movie {
                HStack(spacing: 5) {
                    Text(movie.displayTitle)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                    if hasSoundtrack {
                        Image(systemName: "music.note")
                            .font(.system(size: 9))
                            .foregroundStyle(AppAccent.current)
                    }
                }
                .multilineTextAlignment(.center)
                if !movie.director.isEmpty {
                    Text("Dir. \(movie.director)")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                HStack(spacing: 6) {
                    if !movie.runtime.isEmpty {
                        Text(movie.runtime).font(.system(size: 10)).foregroundStyle(.tertiary)
                    }
                    if !movie.nextFilmIn.isEmpty {
                        if !movie.runtime.isEmpty { Text("·").foregroundStyle(.tertiary) }
                        Text("Next in \(movie.nextFilmIn)").font(.system(size: 10)).foregroundStyle(.tertiary)
                    }
                }
            } else if !viewModel.isLoading {
                Text("No film data available")
                    .font(.system(size: 13)).foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Action Buttons

    private var actionButtonGrid: some View {
        VStack(spacing: 5) {
            HStack(spacing: 5) {
                if player.mode == .off {
                    ActionButton(icon: "play.circle.fill", label: "Stream", color: .red) {
                        player.startStreaming()
                    }
                } else {
                    ActionButton(icon: "play.fill", label: "Watch Live", color: .red) {
                        viewModel.openURL(viewModel.movie?.criterionLiveURL ?? URL(string: "https://www.criterionchannel.com/events/criterion-24-7")!)
                    }
                }
                ActionButton(icon: "text.book.closed.fill", label: "Letterboxd", color: .green) {
                    if let movie = viewModel.movie { viewModel.openURL(movie.letterboxdURL) }
                }.disabled(viewModel.movie == nil)
            }
            HStack(spacing: 5) {
                ActionButton(icon: "square.grid.2x2.fill", label: "Browse", color: .blue) {
                    viewModel.openURL(URL(string: "https://www.criterionchannel.com/browse")!)
                }
                ActionButton(
                    icon: copied ? "checkmark" : "doc.on.doc.fill",
                    label: copied ? "Copied!" : "Copy Title",
                    color: copied ? .green : .orange
                ) {
                    viewModel.copyTitle()
                    withAnimation(.easeInOut(duration: 0.2)) { copied = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation(.easeInOut(duration: 0.2)) { copied = false }
                    }
                }.disabled(viewModel.movie == nil)
            }
        }
    }

    // MARK: - Refresh

    private var refreshButton: some View {
        Button {
            if isLibraryMode {
                Task { await libraryVM.refreshLibrary() }
            } else {
                Task { await viewModel.refresh() }
            }
        } label: {
            Image(systemName: "arrow.clockwise")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(isHoveringRefresh ? .primary : .secondary)
                .rotationEffect(.degrees((viewModel.isLoading || libraryVM.isLoading) ? 360 : 0))
                .animation((viewModel.isLoading || libraryVM.isLoading) ? .linear(duration: 1).repeatForever(autoreverses: false) : .default, value: viewModel.isLoading || libraryVM.isLoading)
        }
        .buttonStyle(.plain)
        .onHover { isHoveringRefresh = $0 }
        .disabled(viewModel.isLoading || libraryVM.isLoading)
        .help(isLibraryMode ? "Refresh library from Criterion" : "Refresh now playing")
    }

    private var tmdbAttribution: some View {
        HStack(spacing: 4) {
            Text("Powered by").font(.system(size: 8)).foregroundStyle(.quaternary)
            Text("TMDB").font(.system(size: 8, weight: .bold)).foregroundStyle(.quaternary)
        }
    }
}

// MARK: - Visual Effect Background

struct VisualEffectBackground: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = .hudWindow
        view.blendingMode = .behindWindow
        view.state = .active
        view.isEmphasized = true
        return view
    }
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}
