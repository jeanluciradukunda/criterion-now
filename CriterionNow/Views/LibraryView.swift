import SwiftUI

struct LibraryView: View {
    @ObservedObject var viewModel: LibraryViewModel
    @State private var searchQuery = ""
    @FocusState private var isSearchFocused: Bool

    private var filteredMovies: [LibraryMovie] {
        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return viewModel.movies }
        return viewModel.movies.filter { $0.matchesSearchQuery(query) }
    }

    var body: some View {
        ZStack {
            if let movie = viewModel.selectedMovie {
                LibraryDetailView(
                    movie: movie,
                    poster: viewModel.selectedMoviePoster,
                    soundtrack: viewModel.selectedMovieSoundtrack,
                    soundtrackArt: viewModel.selectedMovieSoundtrackArt,
                    isLoading: viewModel.isLoadingDetail,
                    onBack: { withAnimation(.easeInOut(duration: 0.3)) { viewModel.clearSelection() } }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .trailing).combined(with: .opacity)
                ))
            } else {
                libraryMain
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.selectedMovie?.id)
        .frame(minWidth: 800, minHeight: 550)
        .task {
            if viewModel.movies.isEmpty {
                await viewModel.loadLibrary()
            }
        }
    }

    // MARK: - Main Library

    private var libraryMain: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                // Nav bar
                navBar
                    .padding(.horizontal, 36)
                    .padding(.top, 44)

                // Header
                libraryHeader
                    .padding(.horizontal, 36)
                    .padding(.top, 24)
                    .padding(.bottom, 32)

                if viewModel.isLoading && viewModel.movies.isEmpty {
                    loadingView
                } else if let error = viewModel.errorMessage, viewModel.movies.isEmpty {
                    errorView(error)
                } else if !viewModel.movies.isEmpty, filteredMovies.isEmpty {
                    noResultsView
                } else if !viewModel.movies.isEmpty {
                    // Scattered poster desk
                    scatteredCollection
                        .padding(.bottom, 60)
                }
            }
        }
    }

    // MARK: - Nav Bar

    private var navBar: some View {
        HStack {
            // Breadcrumb
            HStack(spacing: 6) {
                Image("MenuBarIcon")
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 16, height: 16)
                    .foregroundStyle(.tertiary)
                Text("Criterion Now")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.tertiary)
                Text("/")
                    .font(.system(size: 11))
                    .foregroundStyle(.quaternary)
                Text("My List")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            HStack(spacing: 6) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 10))

                TextField("Search title, director, year, country, decade", text: $searchQuery)
                    .textFieldStyle(.plain)
                    .font(.system(size: 10))
                    .frame(width: 230)
                    .focused($isSearchFocused)

                if !searchQuery.isEmpty {
                    Button {
                        searchQuery = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 9))
                            .foregroundStyle(.tertiary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .foregroundStyle(.secondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .background(.ultraThinMaterial, in: Capsule())
            .overlay {
                Capsule()
                    .strokeBorder(
                        isSearchFocused ? Color.orange.opacity(0.35) : Color.white.opacity(0.08),
                        lineWidth: 0.5
                    )
            }
        }
    }

    // MARK: - Header

    private var libraryHeader: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                Text("My Library")
                    .font(.system(size: 38, weight: .bold, design: .serif))
                    .foregroundStyle(.primary)

                if !viewModel.movies.isEmpty {
                    Text(headerSummary)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(.secondary)
                        .lineSpacing(3)
                        .frame(maxWidth: 400, alignment: .leading)
                }
            }

            Spacer()

            // Right side metadata
            VStack(alignment: .trailing, spacing: 4) {
                if viewModel.isLoading {
                    HStack(spacing: 6) {
                        ProgressView().scaleEffect(0.5).tint(.orange)
                        Text("Updating...")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.orange)
                    }
                }

                Text(dateFormatted())
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.tertiary)
            }
        }
    }

    private func dateFormatted() -> String {
        let f = DateFormatter()
        f.dateFormat = "MMM dd, yyyy"
        return f.string(from: Date())
    }

    private var headerSummary: String {
        if searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "A curated collection of \(viewModel.movies.count) films from the Criterion Channel."
        }

        return "Showing \(filteredMovies.count) of \(viewModel.movies.count) films matching title, director, year, country, or decade."
    }

    // MARK: - Scattered Collection

    private var scatteredCollection: some View {
        let chunks = stride(from: 0, to: filteredMovies.count, by: 5).map {
            Array(filteredMovies[min($0, filteredMovies.count)..<min($0 + 5, filteredMovies.count)])
        }

        return VStack(spacing: 40) {
            ForEach(Array(chunks.enumerated()), id: \.offset) { chunkIndex, chunk in
                ScatteredRow(
                    movies: chunk,
                    rowIndex: chunkIndex,
                    onSelect: { movie in
                        withAnimation(.easeInOut(duration: 0.3)) {
                            viewModel.selectMovie(movie)
                        }
                    }
                )
            }
        }
        .padding(.horizontal, 36)
    }

    // MARK: - Loading / Error

    private var loadingView: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 80)
            ProgressView()
                .scaleEffect(1.5)
                .tint(.orange)
            VStack(spacing: 6) {
                Text("Loading your library...")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.secondary)
                Text("Make sure you've streamed once to be logged in to Criterion Channel")
                    .font(.system(size: 11))
                    .foregroundStyle(.tertiary)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private func errorView(_ error: String) -> some View {
        VStack(spacing: 16) {
            Spacer(minLength: 80)
            Image(systemName: "film.stack")
                .font(.system(size: 40))
                .foregroundStyle(.tertiary)
            Text(error)
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Retry") {
                Task { await viewModel.loadLibrary() }
            }
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(.orange)
            .buttonStyle(.plain)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private var noResultsView: some View {
        VStack(spacing: 16) {
            Spacer(minLength: 80)
            Image(systemName: "magnifyingglass")
                .font(.system(size: 34))
                .foregroundStyle(.tertiary)
            Text("No matching films")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.secondary)
            Text("Try a title, director, year, country, or decade.")
                .font(.system(size: 11))
                .foregroundStyle(.tertiary)
            Button("Clear Search") {
                searchQuery = ""
            }
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(.orange)
            .buttonStyle(.plain)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Scattered Row

struct ScatteredRow: View {
    let movies: [LibraryMovie]
    let rowIndex: Int
    let onSelect: (LibraryMovie) -> Void

    var body: some View {
        GeometryReader { geo in
            let positions = computePositions(in: geo.size, count: movies.count)

            ZStack {
                ForEach(Array(movies.enumerated()), id: \.element.id) { index, movie in
                    let pos = positions[index]

                    ScatteredPosterCard(movie: movie, onSelect: { onSelect(movie) })
                        .frame(width: pos.width, height: pos.height)
                        .rotationEffect(.degrees(pos.rotation))
                        .position(x: pos.x, y: pos.y)
                        .zIndex(pos.zIndex)
                }
            }
        }
        .frame(height: 340)
    }

    struct PosterPosition {
        let x: CGFloat
        let y: CGFloat
        let width: CGFloat
        let height: CGFloat
        let rotation: Double
        let zIndex: Double
    }

    private func computePositions(in size: CGSize, count: Int) -> [PosterPosition] {
        guard count > 0 else { return [] }

        // Seed randomness based on row index for consistency
        var rng = SeededRandom(seed: UInt64(rowIndex * 7 + 42))

        let segmentWidth = size.width / CGFloat(count)
        var positions: [PosterPosition] = []

        for i in 0..<count {
            // Vary sizes — some tall, some standard
            let isFeatured = (i + rowIndex) % 3 == 0
            let width: CGFloat = isFeatured ? 200 : 160
            let height: CGFloat = isFeatured ? 300 : 240

            // Position within segment with jitter
            let baseX = segmentWidth * CGFloat(i) + segmentWidth / 2
            let jitterX = CGFloat(rng.next(in: -20...20))
            let jitterY = CGFloat(rng.next(in: -25...25))

            let x = baseX + jitterX
            let y = size.height / 2 + jitterY

            // Slight rotation
            let rotation = rng.next(in: -4...4)

            // Z-index: featured cards on top
            let zIndex = isFeatured ? 2.0 : 1.0

            positions.append(PosterPosition(
                x: x, y: y,
                width: width, height: height,
                rotation: rotation,
                zIndex: zIndex
            ))
        }

        return positions
    }
}

// Seeded random for consistent scatter per row
struct SeededRandom {
    var state: UInt64

    init(seed: UInt64) { self.state = seed }

    mutating func nextUInt64() -> UInt64 {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return state
    }

    mutating func next(in range: ClosedRange<Double>) -> Double {
        let raw = Double(nextUInt64() % 10000) / 10000.0
        return range.lowerBound + raw * (range.upperBound - range.lowerBound)
    }
}

// MARK: - Scattered Poster Card

struct ScatteredPosterCard: View {
    let movie: LibraryMovie
    let onSelect: () -> Void

    @State private var isHovering = false
    @State private var posterImage: NSImage?

    var body: some View {
        Button(action: onSelect) {
            ZStack {
                // Poster
                posterContent
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                // Hover info card
                if isHovering {
                    infoOverlay
                }

                // Soundtrack badge — shows source icon (Apple or Last.fm)
                if movie.hasSoundtrack && !isHovering {
                    VStack {
                        HStack {
                            Spacer()
                            let icon = movie.soundtrackSource == "lastfm" ? "music.note.tv" : "applelogo"
                            Image(systemName: icon)
                                .font(.system(size: 8, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(5)
                                .background(.orange, in: Circle())
                                .shadow(color: .black.opacity(0.3), radius: 4, y: 2)
                                .padding(6)
                        }
                        Spacer()
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .shadow(
                color: .black.opacity(isHovering ? 0.6 : 0.35),
                radius: isHovering ? 24 : 10,
                y: isHovering ? 12 : 5
            )
            .scaleEffect(isHovering ? 1.08 : 1.0)
            .rotationEffect(.degrees(isHovering ? 0 : 0)) // Straightens via parent removing rotation
            .animation(.easeOut(duration: 0.25), value: isHovering)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeOut(duration: 0.2)) {
                isHovering = hovering
            }
        }
        .zIndex(isHovering ? 100 : 0)
        .task {
            if let url = movie.displayImageURL {
                do {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    posterImage = NSImage(data: data)
                } catch {}
            }
        }
    }

    private var posterContent: some View {
        Group {
            if let poster = posterImage {
                Image(nsImage: poster)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .overlay {
                        VStack(spacing: 4) {
                            Image(systemName: "film")
                                .font(.system(size: 20))
                                .foregroundStyle(.tertiary)
                            Text(movie.title)
                                .font(.system(size: 9, weight: .medium))
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 6)
                        }
                    }
            }
        }
    }

    private var infoOverlay: some View {
        VStack {
            Spacer()
            // Glass info card at bottom
            VStack(alignment: .leading, spacing: 4) {
                if movie.hasSoundtrack {
                    HStack(spacing: 3) {
                        Image(systemName: "music.note")
                            .font(.system(size: 7))
                        Image(systemName: movie.soundtrackSource == "lastfm" ? "music.note.tv" : "applelogo")
                            .font(.system(size: 7))
                    }
                    .foregroundStyle(.orange)
                }

                Text(movie.title)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(2)

                HStack(spacing: 4) {
                    if !movie.year.isEmpty {
                        Text(movie.year)
                    }
                    if !movie.director.isEmpty {
                        if !movie.year.isEmpty { Text("·") }
                        Text(movie.director)
                            .lineLimit(1)
                    }
                }
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(.white.opacity(0.7))
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.ultraThinMaterial)
        }
    }
}
