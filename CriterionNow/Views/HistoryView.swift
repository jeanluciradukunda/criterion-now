import SwiftUI

struct HistoryView: View {
    @StateObject private var viewModel = HistoryViewModel()
    @State private var scrollOffset: CGFloat = 0

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                historyHeader
                    .padding(.horizontal, 20)
                    .padding(.top, 6)
                    .padding(.bottom, 16)

                if !viewModel.isLoaded {
                    loadingView
                } else if viewModel.groupedEntries.isEmpty {
                    emptyView
                } else {
                    // Timeline
                    timelineContent
                        .padding(.horizontal, 16)
                        .padding(.bottom, 20)
                }
            }
        }
        .task {
            await viewModel.load()
        }
    }

    // MARK: - Header

    private var historyHeader: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("WHAT WAS ON")
                .font(.system(size: 9, weight: .bold))
                .tracking(1.5)
                .foregroundStyle(AppAccent.current)

            Text("Viewing History")
                .font(.system(size: 16, weight: .bold, design: .serif))

            if viewModel.totalFilms > 0 {
                HStack(spacing: 12) {
                    statBadge(value: "\(viewModel.totalFilms)", label: "films")
                    statBadge(value: "\(viewModel.uniqueDirectors)", label: "directors")
                    statBadge(value: "\(viewModel.groupedEntries.count)", label: "days")
                }
                .padding(.top, 2)
            }
        }
    }

    private func statBadge(value: String, label: String) -> some View {
        HStack(spacing: 3) {
            Text(value)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundStyle(AppAccent.current)
            Text(label)
                .font(.system(size: 9))
                .foregroundStyle(.tertiary)
        }
    }

    // MARK: - Timeline Content

    private var timelineContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(viewModel.groupedEntries.enumerated()), id: \.offset) { dayIndex, group in
                // Day header
                TimelineDayHeader(label: viewModel.dayLabel(for: group.date))
                    .padding(.leading, 14)
                    .padding(.bottom, 8)
                    .padding(.top, dayIndex > 0 ? 16 : 0)

                // Entries for this day
                ForEach(Array(group.entries.enumerated()), id: \.element.id) { entryIndex, entry in
                    let isFirst = entryIndex == 0 && dayIndex == 0
                    TimelineEntryRow(
                        entry: entry,
                        isCurrentlyPlaying: isFirst,
                        isLast: entryIndex == group.entries.count - 1 && dayIndex == viewModel.groupedEntries.count - 1
                    )
                }
            }
        }
    }

    // MARK: - Loading / Empty

    private var loadingView: some View {
        VStack(spacing: 8) {
            ProgressView().scaleEffect(0.8).tint(AppAccent.current)
            Text("Loading history...").font(.system(size: 10)).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 150)
    }

    private var emptyView: some View {
        VStack(spacing: 10) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 28))
                .foregroundStyle(.tertiary)
            Text("No viewing history yet")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.secondary)
            Text("Films are logged automatically as they play on Criterion 24/7")
                .font(.system(size: 9))
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 150)
    }
}

// MARK: - Day Header

struct TimelineDayHeader: View {
    let label: String

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(AppAccent.current)
                .frame(width: 8, height: 8)

            Text(label.uppercased())
                .font(.system(size: 9, weight: .bold))
                .tracking(1)
                .foregroundStyle(AppAccent.current)

            Rectangle()
                .fill(AppAccent.current.opacity(0.2))
                .frame(height: 0.5)
        }
    }
}

// MARK: - Timeline Entry Row

struct TimelineEntryRow: View {
    let entry: HistoryEntry
    let isCurrentlyPlaying: Bool
    let isLast: Bool

    @State private var appeared = false
    @State private var posterImage: NSImage?

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // Timeline spine
            VStack(spacing: 0) {
                // Connecting line (top)
                Rectangle()
                    .fill(lineGradient)
                    .frame(width: 1.5)
                    .frame(height: 8)

                // Dot
                ZStack {
                    if isCurrentlyPlaying {
                        // Pulsing glow for current film
                        Circle()
                            .fill(AppAccent.current.opacity(0.3))
                            .frame(width: 16, height: 16)
                            .scaleEffect(appeared ? 1.5 : 1.0)
                            .opacity(appeared ? 0 : 0.6)
                            .animation(.easeOut(duration: 1.5).repeatForever(autoreverses: false), value: appeared)
                    }

                    Circle()
                        .fill(isCurrentlyPlaying ? AppAccent.current : .white.opacity(0.3))
                        .frame(width: 8, height: 8)

                    if isCurrentlyPlaying {
                        Circle()
                            .fill(AppAccent.current)
                            .frame(width: 4, height: 4)
                    }
                }

                // Connecting line (bottom)
                if !isLast {
                    Rectangle()
                        .fill(lineGradient)
                        .frame(width: 1.5)
                        .frame(maxHeight: .infinity)
                }
            }
            .frame(width: 30)

            // Content card
            entryCard
                .padding(.leading, 8)
                .padding(.bottom, 10)
                .opacity(appeared ? 1 : 0)
                .offset(x: appeared ? 0 : 20)
                .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.05), value: appeared)
        }
        .onAppear {
            appeared = true
            loadPoster()
        }
    }

    private var lineGradient: LinearGradient {
        LinearGradient(
            colors: [AppAccent.current.opacity(0.4), .white.opacity(0.1)],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    // MARK: - Entry Card

    private var entryCard: some View {
        HStack(alignment: .top, spacing: 10) {
            // Mini poster
            if let poster = posterImage {
                Image(nsImage: poster)
                    .resizable()
                    .aspectRatio(2/3, contentMode: .fill)
                    .frame(width: 42, height: 63)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
            } else {
                RoundedRectangle(cornerRadius: 5)
                    .fill(.ultraThinMaterial)
                    .frame(width: 42, height: 63)
                    .overlay {
                        Image(systemName: "film")
                            .font(.system(size: 12))
                            .foregroundStyle(.tertiary)
                    }
            }

            // Info
            VStack(alignment: .leading, spacing: 3) {
                // Time
                Text(entry.timeString)
                    .font(.system(size: 9, weight: .semibold, design: .monospaced))
                    .foregroundStyle(isCurrentlyPlaying ? AnyShapeStyle(AppAccent.current) : AnyShapeStyle(.tertiary))

                // Title
                Text(entry.displayTitle)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.primary)
                    .opacity(isCurrentlyPlaying ? 1.0 : 0.85)
                    .lineLimit(2)

                // Director
                if !entry.director.isEmpty {
                    Text("Dir. \(entry.director)")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(.secondary)
                }

                // Runtime
                if !entry.runtime.isEmpty {
                    Text(entry.runtime)
                        .font(.system(size: 8))
                        .foregroundStyle(.tertiary)
                }

                // Currently playing badge
                if isCurrentlyPlaying {
                    HStack(spacing: 3) {
                        Circle()
                            .fill(.red)
                            .frame(width: 4, height: 4)
                        Text("NOW")
                            .font(.system(size: 7, weight: .bold, design: .monospaced))
                    }
                    .foregroundStyle(.red)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.red.opacity(0.1), in: Capsule())
                    .padding(.top, 1)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(10)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(isCurrentlyPlaying ? AppAccent.current.opacity(0.06) : .white.opacity(0.03))
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(
                            isCurrentlyPlaying ? AppAccent.current.opacity(0.2) : .white.opacity(0.06),
                            lineWidth: 0.5
                        )
                }
        }
    }

    private func loadPoster() {
        guard let urlStr = entry.posterURL, let url = URL(string: urlStr) else { return }
        Task {
            if let cached = await CacheService.shared.getCachedImage(url: url) {
                posterImage = cached
            } else {
                do {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    if let img = NSImage(data: data) {
                        posterImage = img
                        await CacheService.shared.cacheImage(url: url, image: img)
                    }
                } catch {}
            }
        }
    }
}
