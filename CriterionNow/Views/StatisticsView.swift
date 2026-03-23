import SwiftUI

// MARK: - Inline Statistics View (portrait, for menu popover)

struct StatisticsInlineView: View {
    @ObservedObject var statsVM: StatisticsViewModel
    @ObservedObject var libraryVM: LibraryViewModel
    let movies: [LibraryMovie]

    var body: some View {
        VStack(spacing: 0) {
            // Top: title + stats strip
            statsHeader
                .padding(.horizontal, 16)
                .padding(.top, 4)
                .padding(.bottom, 6)

            // Center: Globe viewport
            if !statsVM.countryGroups.isEmpty {
                GlobeView(
                    countryGroups: statsVM.countryGroups,
                    onCountryTap: { group in
                        withAnimation(.easeInOut(duration: 0.2)) {
                            statsVM.selectedCountry = group
                        }
                    }
                )
                .frame(maxHeight: .infinity)
                .clipped()
            } else {
                Spacer()
                VStack(spacing: 8) {
                    ProgressView().scaleEffect(0.8).tint(.orange)
                    Text("Loading globe...").font(.system(size: 10)).foregroundStyle(.secondary)
                }
                Spacer()
            }

            // Bottom: selected country card or summary
            bottomCard
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
        }
        .task {
            var films = movies
            if films.isEmpty {
                if let stored = await LocalStore.shared.loadLibrary() {
                    films = stored.map { LibraryMovie.fromStored($0) }
                }
            }
            statsVM.load(from: films)
        }
    }

    // MARK: - Header

    private var statsHeader: some View {
        VStack(spacing: 3) {
            if let collection = libraryVM.activeCollection {
                // Collection mode — show back button + collection name
                HStack(spacing: 6) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            libraryVM.exitCollection()
                            // Force reload with full library
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                statsVM.load(from: libraryVM.movies)
                            }
                        }
                    } label: {
                        HStack(spacing: 3) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 8, weight: .bold))
                            Text("All Films")
                                .font(.system(size: 9, weight: .medium))
                        }
                        .foregroundStyle(AppAccent.current)
                    }
                    .buttonStyle(.plain)

                    Spacer()
                }

                Text(collection.title.uppercased())
                    .font(.system(size: 8, weight: .bold))
                    .tracking(1)
                    .foregroundStyle(AppAccent.current)
                    .lineLimit(1)
            } else {
                Text("YOUR CINEMA WORLD")
                    .font(.system(size: 8, weight: .bold))
                    .tracking(1.5)
                    .foregroundStyle(.orange)
            }

            HStack(spacing: 10) {
                miniStat("\(statsVM.totalFilms)", "films")
                miniStat("\(statsVM.totalCountries)", "countries")
                miniStat("\(statsVM.directorGroups.count)", "directors")
                if !statsVM.yearRange.isEmpty {
                    miniStat(statsVM.yearRange, "span")
                }
            }
        }
    }

    private func miniStat(_ value: String, _ label: String) -> some View {
        VStack(spacing: 0) {
            Text(value)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundStyle(.orange)
            Text(label)
                .font(.system(size: 7))
                .foregroundStyle(.tertiary)
        }
    }

    // MARK: - Bottom Card

    private var bottomCard: some View {
        Group {
            if let country = statsVM.selectedCountry {
                selectedCountryCard(country)
            } else {
                summaryCard
            }
        }
    }

    private var summaryCard: some View {
        HStack(spacing: 12) {
            // Top 3 countries
            VStack(alignment: .leading, spacing: 3) {
                Text("TOP COUNTRIES")
                    .font(.system(size: 7, weight: .bold))
                    .tracking(1)
                    .foregroundStyle(.tertiary)

                ForEach(statsVM.countryGroups.prefix(4)) { g in
                    Button {
                        withAnimation { statsVM.selectedCountry = g }
                    } label: {
                        HStack(spacing: 4) {
                            Text(g.country)
                                .font(.system(size: 9))
                                .lineLimit(1)
                            Spacer()
                            Text("\(g.count)")
                                .font(.system(size: 8, weight: .bold, design: .monospaced))
                                .foregroundStyle(.orange)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Top 3 directors
            VStack(alignment: .leading, spacing: 3) {
                Text("TOP DIRECTORS")
                    .font(.system(size: 7, weight: .bold))
                    .tracking(1)
                    .foregroundStyle(.tertiary)

                ForEach(statsVM.directorGroups.prefix(4)) { g in
                    HStack(spacing: 4) {
                        Text(g.name)
                            .font(.system(size: 9))
                            .lineLimit(1)
                        Spacer()
                        Text("\(g.count)")
                            .font(.system(size: 8, weight: .bold, design: .monospaced))
                            .foregroundStyle(.orange)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(10)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(.white.opacity(0.08), lineWidth: 0.5)
                }
        }
    }

    private func selectedCountryCard(_ group: CountryFilmGroup) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Button {
                    withAnimation { statsVM.selectedCountry = nil }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(.orange)
                }
                .buttonStyle(.plain)

                Text(group.country)
                    .font(.system(size: 12, weight: .bold))
                Text("· \(group.count) films")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                Spacer()
            }

            // Poster row
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(group.films.prefix(10), id: \.id) { film in
                        VStack(spacing: 2) {
                            AsyncImage(url: film.displayImageURL) { phase in
                                if case .success(let img) = phase {
                                    img.resizable().aspectRatio(2/3, contentMode: .fill)
                                        .frame(width: 36, height: 54).clipped()
                                } else {
                                    RoundedRectangle(cornerRadius: 3).fill(.quaternary)
                                        .frame(width: 36, height: 54)
                                }
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 4))

                            Text(film.title)
                                .font(.system(size: 6))
                                .lineLimit(1)
                                .frame(width: 36)
                        }
                    }
                }
            }
        }
        .padding(10)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(.orange.opacity(0.15), lineWidth: 0.5)
                }
        }
    }
}

// MARK: - Windowed Statistics View (separate window, wider layout)

struct StatisticsWindowView: View {
    @ObservedObject var statsVM: StatisticsViewModel
    let movies: [LibraryMovie]

    var body: some View {
        HSplitView {
            ZStack {
                Color(red: 0.06, green: 0.06, blue: 0.08)

                if !statsVM.countryGroups.isEmpty {
                    GlobeView(
                        countryGroups: statsVM.countryGroups,
                        onCountryTap: { group in
                            withAnimation { statsVM.selectedCountry = group }
                        }
                    )
                } else {
                    ProgressView().scaleEffect(1.2).tint(.orange)
                }

                // Overlay stats
                VStack(alignment: .leading) {
                    Text("YOUR CINEMA WORLD")
                        .font(.system(size: 10, weight: .bold)).tracking(1.5).foregroundStyle(.orange)
                    HStack(spacing: 12) {
                        statPill("\(statsVM.totalFilms)", "films")
                        statPill("\(statsVM.totalCountries)", "countries")
                        statPill("\(statsVM.directorGroups.count)", "directors")
                    }
                    Spacer()
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .frame(minWidth: 400)

            // Sidebar
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    if let c = statsVM.selectedCountry {
                        Button { withAnimation { statsVM.selectedCountry = nil } } label: {
                            HStack(spacing: 3) {
                                Image(systemName: "chevron.left").font(.system(size: 9, weight: .bold))
                                Text("Back").font(.system(size: 10))
                            }.foregroundStyle(.orange)
                        }.buttonStyle(.plain)

                        Text(c.country).font(.system(size: 16, weight: .bold, design: .serif))
                        Text("\(c.count) films").font(.system(size: 11)).foregroundStyle(.secondary)

                        let cols = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
                        LazyVGrid(columns: cols, spacing: 6) {
                            ForEach(c.films, id: \.id) { film in
                                VStack(spacing: 2) {
                                    AsyncImage(url: film.displayImageURL) { p in
                                        if case .success(let i) = p { i.resizable().aspectRatio(2/3, contentMode: .fill).frame(height: 72).clipped() }
                                        else { RoundedRectangle(cornerRadius: 3).fill(.quaternary).frame(height: 72) }
                                    }.clipShape(RoundedRectangle(cornerRadius: 4))
                                    Text(film.title).font(.system(size: 7)).lineLimit(2).multilineTextAlignment(.center)
                                }
                            }
                        }
                    } else {
                        ForEach(statsVM.directorGroups.prefix(15)) { g in
                            HStack { Text(g.name).font(.system(size: 10)).lineLimit(1); Spacer(); Text("\(g.count)").font(.system(size: 9, weight: .bold, design: .monospaced)).foregroundStyle(.orange) }
                        }
                    }
                }.padding(12)
            }
            .background(.regularMaterial)
            .frame(width: 240)
        }
        .task {
            var films = movies
            if films.isEmpty {
                if let stored = await LocalStore.shared.loadLibrary() { films = stored.map { LibraryMovie.fromStored($0) } }
            }
            statsVM.load(from: films)
        }
    }

    private func statPill(_ v: String, _ l: String) -> some View {
        VStack(spacing: 1) {
            Text(v).font(.system(size: 12, weight: .bold, design: .monospaced)).foregroundStyle(.orange)
            Text(l).font(.system(size: 7)).foregroundStyle(.tertiary)
        }.padding(.horizontal, 6).padding(.vertical, 3).background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 5))
    }
}
