import SwiftUI

struct InlineLibraryView: View {
    @ObservedObject var libraryVM: LibraryViewModel
    @Binding var currentIndex: Int
    let onFocusChange: (LibraryMovie) -> Void
    let onSoundtrackTap: (LibraryMovie) -> Void

    @State private var isFlipped: Bool = false
    @State private var dragOffset: CGFloat = 0
    @State private var collectionIndex: Int = 0
    @State private var swipeAccumulator: CGFloat = 0
    @State private var swipeCooldown: Bool = false
    @State private var searchQuery: String = ""
    @State private var selectedDecade: String?
    @State private var selectedCountry: String?
    @FocusState private var isSearchFocused: Bool

    /// Base movies — collection or full library
    private var baseMovies: [LibraryMovie] {
        if libraryVM.activeCollection != nil {
            return libraryVM.collectionFilms
        }
        return libraryVM.movies
    }

    /// Filtered movies — search + filters applied to base
    private var displayMovies: [LibraryMovie] {
        var films = baseMovies

        let q = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        if !q.isEmpty {
            films = films.filter { $0.matchesSearchQuery(q) }
        }

        if let decade = selectedDecade {
            films = films.filter { $0.decadeLabel == decade }
        }

        if let country = selectedCountry {
            films = films.filter { $0.primaryCountry == country }
        }

        return films
    }

    /// Available decades from the base movies (for filter chips)
    private var availableDecades: [String] {
        let decades = Set(baseMovies.compactMap(\.decadeLabel))
        return decades.sorted()
    }

    /// Available countries from the base movies (for filter chips)
    private var availableCountries: [String] {
        let countries = baseMovies.reduce(into: [String: Int]()) { dict, movie in
            if !movie.primaryCountry.isEmpty { dict[movie.primaryCountry, default: 0] += 1 }
        }
        return countries.sorted { $0.value > $1.value }.prefix(10).map { $0.key }
    }

    private var hasActiveFilters: Bool {
        !searchQuery.isEmpty || selectedDecade != nil || selectedCountry != nil
    }

    private var activeIndex: Binding<Int> {
        if libraryVM.activeCollection != nil {
            return $collectionIndex
        }
        return $currentIndex
    }

    var body: some View {
        VStack(spacing: 6) {
            if libraryVM.isLoadingCollection {
                VStack(spacing: 0) {
                    // Back button always accessible even while loading
                    HStack {
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                goBackToLibrary()
                            }
                        } label: {
                            HStack(spacing: 3) {
                                Image(systemName: "chevron.left").font(.system(size: 8, weight: .bold))
                                Text("Back").font(.system(size: 9, weight: .medium))
                            }
                            .foregroundStyle(AppAccent.current)
                        }
                        .buttonStyle(.plain)
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    loadingCollectionView
                }
            } else if libraryVM.isLoading && libraryVM.movies.isEmpty {
                loadingView
            } else if libraryVM.movies.isEmpty {
                emptyView
            } else if displayMovies.isEmpty {
                VStack(spacing: 0) {
                    if libraryVM.activeCollection != nil {
                        HStack {
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    goBackToLibrary()
                                }
                            } label: {
                                HStack(spacing: 3) {
                                    Image(systemName: "chevron.left").font(.system(size: 8, weight: .bold))
                                    Text("Back").font(.system(size: 9, weight: .medium))
                                }
                                .foregroundStyle(AppAccent.current)
                            }
                            .buttonStyle(.plain)
                            Spacer()
                        }
                        .padding(.horizontal, 24)
                    }
                    emptyView
                }
            } else {
                // Back button — separate row, big tap target
                if libraryVM.activeCollection != nil {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            goBackToLibrary()
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 9, weight: .bold))
                            Text("My List")
                                .font(.system(size: 10, weight: .medium))
                        }
                        .foregroundStyle(AppAccent.current)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(AppAccent.current.opacity(0.1), in: Capsule())
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 2)
                }

                // Header — collection or main library
                HStack {
                    Text("\(safeIndex + 1) / \(displayMovies.count)")
                        .font(.system(size: 9, weight: .semibold, design: .monospaced))
                        .foregroundStyle(.tertiary)
                    Spacer()
                    Text(libraryVM.activeCollection?.title.uppercased() ?? "MY LIST")
                        .font(.system(size: 9, weight: .bold))
                        .tracking(1)
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                }
                .padding(.horizontal, 24)

                // Card stack with spread cards behind
                cardStack
                    .id(libraryVM.activeCollection?.id ?? "library")
                    .padding(.horizontal, 10)
                    .onAppear { notifyFocus() }

                // Navigation
                navigationControls
                    .padding(.horizontal, 20)
                    .padding(.bottom, 2)

                // Search + filter below the carousel
                searchAndFilters
                    .padding(.horizontal, 14)
                    .padding(.top, 4)
            }
        }
        // Clamp indices when data changes
        .onChange(of: libraryVM.activeCollection) { _, _ in
            clampIndex()
        }
        .onChange(of: displayMovies.count) { _, _ in
            clampIndex()
        }
        // Keyboard arrow support
        .onKeyPress(.leftArrow) { navigatePrev(); return .handled }
        .onKeyPress(.rightArrow) { navigateNext(); return .handled }
        .onKeyPress(.space) { toggleFlip(); return .handled }
        // Two-finger trackpad swipe
        .background {
            TrackpadSwipeView(
                onSwipeLeft: { navigateNext() },
                onSwipeRight: { navigatePrev() }
            )
        }
    }

    /// Safe index that's always within bounds
    private var safeIndex: Int {
        let count = displayMovies.count
        guard count > 0 else { return 0 }
        return min(activeIndex.wrappedValue, count - 1)
    }

    /// Clamp active index to valid range
    private func clampIndex() {
        let count = displayMovies.count
        if count == 0 { return }
        if activeIndex.wrappedValue >= count {
            activeIndex.wrappedValue = max(0, count - 1)
        }
    }

    /// Go back from collection to main library
    private func goBackToLibrary() {
        isFlipped = false
        collectionIndex = 0
        searchQuery = ""
        selectedDecade = nil
        selectedCountry = nil
        // Reset main library index to 0 so the carousel starts fresh
        currentIndex = 0
        libraryVM.exitCollection()
    }

    // MARK: - Card Stack (spread cards behind)

    private var cardStack: some View {
        let movies = displayMovies
        let idx = safeIndex
        guard !movies.isEmpty, idx >= 0, idx < movies.count else {
            return AnyView(EmptyView())
        }
        let movie = movies[idx]

        return AnyView(ZStack {
            // Background spread cards (next/prev peeking)
            if idx + 2 < movies.count {
                spreadCard(offset: 2)
                    .offset(x: 16, y: 0)
                    .scaleEffect(0.88)
                    .opacity(0.15)
            }
            if idx + 1 < movies.count {
                spreadCard(offset: 1)
                    .offset(x: 8, y: 0)
                    .scaleEffect(0.94)
                    .opacity(0.3)
            }

            // Main card
            mainCard(movie: movie)
                .offset(x: dragOffset)
                .gesture(
                    DragGesture(minimumDistance: 20)
                        .onChanged { value in
                            dragOffset = value.translation.width * 0.4
                        }
                        .onEnded { value in
                            if value.translation.width < -50 {
                                navigateNext()
                            } else if value.translation.width > 50 {
                                navigatePrev()
                            }
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                dragOffset = 0
                            }
                        }
                )
        }
        .frame(height: 360))
    }

    private func spreadCard(offset: Int) -> some View {
        let movies = displayMovies
        let idx = min(activeIndex.wrappedValue + offset, movies.count - 1)
        let movie = movies[idx]

        return AsyncImage(url: movie.displayImageURL) { phase in
            switch phase {
            case .success(let image):
                image.resizable().aspectRatio(2/3, contentMode: .fit)
            default:
                RoundedRectangle(cornerRadius: 12).fill(.ultraThinMaterial)
                    .aspectRatio(2/3, contentMode: .fit)
            }
        }
        .frame(maxHeight: 340)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.15), radius: 6, y: 3)
        .rotationEffect(.degrees(Double(offset) * 2.5))
    }

    // MARK: - Main Card (Flip)

    private func mainCard(movie: LibraryMovie) -> some View {
        ZStack {
            // Back
            cardBack(movie: movie)
                .rotation3DEffect(
                    .degrees(isFlipped ? 0 : 180),
                    axis: (x: 0, y: 1, z: 0),
                    perspective: 0.4
                )
                .opacity(isFlipped ? 1 : 0)

            // Front
            cardFront(movie: movie)
                .rotation3DEffect(
                    .degrees(isFlipped ? -180 : 0),
                    axis: (x: 0, y: 1, z: 0),
                    perspective: 0.4
                )
                .opacity(isFlipped ? 0 : 1)
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isFlipped)
        .onTapGesture { toggleFlip() }
    }

    private func toggleFlip() {
        withAnimation { isFlipped.toggle() }
    }

    // MARK: - Card Front

    private func cardFront(movie: LibraryMovie) -> some View {
        ZStack(alignment: .bottom) {
            // Poster — fills the card completely
            AsyncImage(url: movie.displayImageURL) { phase in
                switch phase {
                case .success(let image):
                    image.resizable()
                        .aspectRatio(2/3, contentMode: .fill)
                        .frame(maxHeight: 360)
                        .clipped()
                default:
                    RoundedRectangle(cornerRadius: 0)
                        .fill(.ultraThinMaterial)
                        .aspectRatio(2/3, contentMode: .fill)
                        .frame(maxHeight: 360)
                        .overlay {
                            VStack(spacing: 4) {
                                Image(systemName: "film").font(.system(size: 28)).foregroundStyle(.tertiary)
                                Text(movie.title).font(.system(size: 10)).foregroundStyle(.secondary)
                                    .lineLimit(2).multilineTextAlignment(.center).padding(.horizontal, 12)
                            }
                        }
                }
            }

            // Bottom gradient + info
            LinearGradient(
                colors: [.clear, .black.opacity(0.85)],
                startPoint: .center,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 3) {
                Spacer()

                HStack(spacing: 4) {
                    if movie.itemType.isCollection {
                        Text("COLLECTION")
                            .font(.system(size: 7, weight: .bold, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.8))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.ultraThinMaterial, in: Capsule())
                    } else if movie.hasSoundtrack {
                        Image(systemName: movie.soundtrackSource == "lastfm" ? "music.note.tv" : "applelogo")
                            .font(.system(size: 7))
                            .foregroundStyle(AppAccent.current)
                            .padding(3)
                            .background(.orange.opacity(0.2), in: Circle())
                    }
                    Spacer()
                    // Flip hint overlaid
                    HStack(spacing: 3) {
                        Image(systemName: "arrow.uturn.right")
                            .font(.system(size: 7))
                        Text("Tap to flip")
                            .font(.system(size: 7, weight: .medium))
                    }
                    .foregroundStyle(.white.opacity(0.4))
                }

                Text(movie.title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(2)

                HStack(spacing: 4) {
                    if !movie.year.isEmpty { Text(movie.year) }
                    if !movie.director.isEmpty {
                        if !movie.year.isEmpty { Text("·") }
                        Text(movie.director).lineLimit(1)
                    }
                }
                .font(.system(size: 10))
                .foregroundStyle(.white.opacity(0.7))
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxHeight: 360)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.35), radius: 14, y: 7)
    }

    // MARK: - Card Back

    private func cardBack(movie: LibraryMovie) -> some View {
        VStack(spacing: 0) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(movie.displayTitle)
                        .font(.system(size: 16, weight: .bold))
                    if !movie.director.isEmpty {
                        HStack(spacing: 0) {
                            Text("Dir. ").foregroundStyle(.tertiary)
                            Text(movie.director).foregroundStyle(.secondary)
                        }
                        .font(.system(size: 11, weight: .medium))
                    }
                    HStack(spacing: 6) {
                        if !movie.runtime.isEmpty {
                            Text(movie.runtime).font(.system(size: 10)).foregroundStyle(.tertiary)
                        }
                        if movie.hasSoundtrack {
                            HStack(spacing: 3) {
                                Image(systemName: "music.note").font(.system(size: 8))
                                Text("Soundtrack").font(.system(size: 9, weight: .medium))
                            }
                            .foregroundStyle(AppAccent.current)
                        }
                    }
                    if !movie.overview.isEmpty {
                        Text(movie.overview)
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                            .lineSpacing(3)
                    }

                    // Flip back hint
                    HStack {
                        Spacer()
                        HStack(spacing: 3) {
                            Image(systemName: "arrow.uturn.left").font(.system(size: 7))
                            Text("Tap to flip back").font(.system(size: 7, weight: .medium))
                        }
                        .foregroundStyle(.quaternary)
                    }
                }
                .padding(16)
            }

            HStack(spacing: 6) {
                if movie.itemType.isCollection {
                    // Collection: "View Collection" is the primary action
                    cardActionButton(icon: "rectangle.stack.fill", label: "View Films", color: .orange) {
                        collectionIndex = 0
                        isFlipped = false
                        searchQuery = ""
                        selectedDecade = nil
                        selectedCountry = nil
                        Task { await libraryVM.loadCollection(movie) }
                    }
                    cardActionButton(icon: "safari", label: "Criterion", color: .red) {
                        NSWorkspace.shared.open(movie.criterionURL)
                    }
                } else {
                    cardActionButton(icon: "play.fill", label: "Criterion", color: .red) {
                        NSWorkspace.shared.open(movie.criterionURL)
                    }
                    cardActionButton(icon: "text.book.closed.fill", label: "Letterboxd", color: .green) {
                        NSWorkspace.shared.open(movie.letterboxdURL)
                    }
                    if movie.hasSoundtrack {
                        cardActionButton(icon: "music.note", label: "Soundtrack", color: .orange) {
                            onSoundtrackTap(movie)
                        }
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
        .frame(maxHeight: 360)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(
                            LinearGradient(
                                colors: [.white.opacity(0.15), .white.opacity(0.03)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.5
                        )
                }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.35), radius: 14, y: 7)
    }

    private func cardActionButton(icon: String, label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 3) {
                Image(systemName: icon).font(.system(size: 8))
                Text(label).font(.system(size: 8, weight: .medium))
            }
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .frame(maxWidth: .infinity)
            .background {
                RoundedRectangle(cornerRadius: 7)
                    .fill(color.opacity(0.1))
                    .overlay {
                        RoundedRectangle(cornerRadius: 7)
                            .strokeBorder(color.opacity(0.2), lineWidth: 0.5)
                    }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Navigation

    private var navigationControls: some View {
        let idx = safeIndex
        let total = displayMovies.count

        return HStack(spacing: 14) {
            Button { navigatePrev() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(idx > 0 ? .primary : .quaternary)
                    .frame(width: 24, height: 24)
                    .background(idx > 0 ? Color.white.opacity(0.06) : Color.clear, in: Circle())
            }
            .buttonStyle(.plain)
            .disabled(idx == 0)

            HStack(spacing: 3) {
                let start = max(0, idx - 3)
                let end = min(total, start + 7)
                ForEach(start..<end, id: \.self) { i in
                    Circle()
                        .fill(i == idx ? Color.orange : Color.white.opacity(0.15))
                        .frame(width: i == idx ? 6 : 3, height: i == idx ? 6 : 3)
                }
            }
            .animation(.easeOut(duration: 0.15), value: idx)

            Button { navigateNext() } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(idx < total - 1 ? .primary : .quaternary)
                    .frame(width: 24, height: 24)
                    .background(idx < total - 1 ? Color.white.opacity(0.06) : Color.clear, in: Circle())
            }
            .buttonStyle(.plain)
            .disabled(idx >= total - 1)
        }
    }

    private func navigateNext() {
        let movies = displayMovies
        guard activeIndex.wrappedValue < movies.count - 1 else { return }
        isFlipped = false
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            activeIndex.wrappedValue += 1
        }
        notifyFocus()
    }

    private func navigatePrev() {
        guard activeIndex.wrappedValue > 0 else { return }
        isFlipped = false
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            activeIndex.wrappedValue -= 1
        }
        notifyFocus()
    }

    private func notifyFocus() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            let movies = displayMovies
            let idx = safeIndex
            guard !movies.isEmpty, idx >= 0, idx < movies.count else { return }
            onFocusChange(movies[idx])
        }
    }

    // MARK: - Loading / Empty

    // MARK: - Search + Filter

    private var searchAndFilters: some View {
        VStack(spacing: 6) {
            // Search bar
            HStack(spacing: 6) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 10))
                    .foregroundStyle(.tertiary)

                TextField("Search...", text: $searchQuery)
                    .textFieldStyle(.plain)
                    .font(.system(size: 11))
                    .focused($isSearchFocused)
                    .onChange(of: searchQuery) { _, _ in resetIndexForFilter() }

                if hasActiveFilters {
                    Button { clearFilters() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 9))
                            .foregroundStyle(.tertiary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background {
                RoundedRectangle(cornerRadius: 7)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: 7)
                            .strokeBorder(isSearchFocused ? AppAccent.current.opacity(0.3) : Color.white.opacity(0.06), lineWidth: 0.5)
                    }
            }

            // Filter chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    // Decade chips
                    ForEach(availableDecades, id: \.self) { decade in
                        filterChip(label: decade, isSelected: selectedDecade == decade) {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                selectedDecade = selectedDecade == decade ? nil : decade
                                resetIndexForFilter()
                            }
                        }
                    }

                    if !availableDecades.isEmpty && !availableCountries.isEmpty {
                        Divider().frame(height: 12)
                    }

                    // Country chips
                    ForEach(availableCountries, id: \.self) { country in
                        filterChip(label: country, isSelected: selectedCountry == country) {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                selectedCountry = selectedCountry == country ? nil : country
                                resetIndexForFilter()
                            }
                        }
                    }
                }
            }

            // Active filter summary
            if hasActiveFilters {
                HStack(spacing: 4) {
                    Text("\(displayMovies.count) of \(baseMovies.count) films")
                        .font(.system(size: 8, weight: .medium, design: .monospaced))
                        .foregroundStyle(AppAccent.current)
                    Spacer()
                    Button("Clear all") { clearFilters() }
                        .font(.system(size: 8, weight: .medium))
                        .foregroundStyle(.tertiary)
                        .buttonStyle(.plain)
                }
            }
        }
    }

    private func filterChip(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 8, weight: isSelected ? .bold : .medium))
                .foregroundStyle(isSelected ? .white : .secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background {
                    if isSelected {
                        Capsule().fill(AppAccent.current.opacity(0.6))
                    } else {
                        Capsule().fill(Color.white.opacity(0.05))
                            .overlay { Capsule().strokeBorder(Color.white.opacity(0.06), lineWidth: 0.5) }
                    }
                }
        }
        .buttonStyle(.plain)
    }

    private func clearFilters() {
        searchQuery = ""
        selectedDecade = nil
        selectedCountry = nil
        resetIndexForFilter()
    }

    private func resetIndexForFilter() {
        // Reset carousel to first item when filters change
        activeIndex.wrappedValue = 0
        isFlipped = false
    }

    private var loadingCollectionView: some View {
        VStack(spacing: 8) {
            ProgressView().scaleEffect(0.8).tint(.orange)
            Text("Loading collection...")
                .font(.system(size: 10)).foregroundStyle(.secondary)
            if let name = libraryVM.activeCollection?.title {
                Text(name)
                    .font(.system(size: 9, weight: .medium)).foregroundStyle(.tertiary)
            }
        }
        .frame(height: 300)
    }

    private var loadingView: some View {
        VStack(spacing: 8) {
            ProgressView().scaleEffect(0.8).tint(.orange)
            Text("Loading library...").font(.system(size: 10)).foregroundStyle(.secondary)
        }
        .frame(height: 200)
    }

    private var emptyView: some View {
        VStack(spacing: 8) {
            Image(systemName: "books.vertical").font(.system(size: 24)).foregroundStyle(.tertiary)
            Text("No films in your list").font(.system(size: 11)).foregroundStyle(.secondary)
            Text("Stream once to log in, then add films").font(.system(size: 9)).foregroundStyle(.tertiary)
            Button("Load Library") {
                Task { await libraryVM.loadLibrary() }
            }
            .font(.system(size: 10, weight: .medium)).foregroundStyle(AppAccent.current).buttonStyle(.plain)
        }
        .frame(height: 200)
    }
}

// MARK: - Trackpad Two-Finger Swipe

struct TrackpadSwipeView: NSViewRepresentable {
    let onSwipeLeft: () -> Void
    let onSwipeRight: () -> Void

    func makeNSView(context: Context) -> SwipeNSView {
        let view = SwipeNSView()
        view.onSwipeLeft = onSwipeLeft
        view.onSwipeRight = onSwipeRight
        return view
    }

    func updateNSView(_ nsView: SwipeNSView, context: Context) {
        nsView.onSwipeLeft = onSwipeLeft
        nsView.onSwipeRight = onSwipeRight
    }
}

class SwipeNSView: NSView {
    var onSwipeLeft: (() -> Void)?
    var onSwipeRight: (() -> Void)?

    private var scrollAccumulator: CGFloat = 0
    private var isProcessing = false
    private let threshold: CGFloat = 30

    override var acceptsFirstResponder: Bool { true }

    override func scrollWheel(with event: NSEvent) {
        // Only handle trackpad (momentum) scrolling, not mouse wheel
        guard event.momentumPhase != [] || event.phase != [] else {
            super.scrollWheel(with: event)
            return
        }

        // Use horizontal scroll delta (two-finger horizontal swipe)
        let delta = event.scrollingDeltaX

        // Also detect primarily-horizontal gestures from deltaX
        if abs(delta) > abs(event.scrollingDeltaY) {
            scrollAccumulator += delta
        }

        if event.phase == .ended || event.momentumPhase == .ended {
            if !isProcessing {
                if scrollAccumulator > threshold {
                    isProcessing = true
                    onSwipeRight?()
                    resetAfterDelay()
                } else if scrollAccumulator < -threshold {
                    isProcessing = true
                    onSwipeLeft?()
                    resetAfterDelay()
                }
            }
            scrollAccumulator = 0
        }
    }

    private func resetAfterDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
            self?.isProcessing = false
        }
    }
}
