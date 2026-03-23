import WidgetKit
import SwiftUI
import AppKit

// MARK: - Timeline Entry

struct CriterionEntry: TimelineEntry {
    let date: Date
    let movieTitle: String
    let movieYear: String
    let director: String
    let runtime: String
    let nextFilmIn: String
    let progress: Double
    let posterImage: NSImage?
    let hasData: Bool
}

// MARK: - Timeline Provider

struct CriterionProvider: TimelineProvider {
    func placeholder(in context: Context) -> CriterionEntry {
        CriterionEntry(
            date: Date(),
            movieTitle: "Loading...",
            movieYear: "",
            director: "",
            runtime: "",
            nextFilmIn: "",
            progress: 0,
            posterImage: nil,
            hasData: false
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (CriterionEntry) -> ()) {
        completion(makeEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CriterionEntry>) -> ()) {
        let entry = makeEntry()
        // Refresh every 5 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 5, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func makeEntry() -> CriterionEntry {
        var posterImage: NSImage?
        if let data = WidgetSharedData.posterImageData {
            posterImage = NSImage(data: data)
        }

        return CriterionEntry(
            date: Date(),
            movieTitle: WidgetSharedData.movieTitle,
            movieYear: WidgetSharedData.movieYear,
            director: WidgetSharedData.movieDirector,
            runtime: WidgetSharedData.movieRuntime,
            nextFilmIn: WidgetSharedData.nextFilmIn,
            progress: WidgetSharedData.progress,
            posterImage: posterImage,
            hasData: WidgetSharedData.hasData
        )
    }
}

// MARK: - Widget Views

struct CriterionWidgetSmall: View {
    let entry: CriterionEntry

    var body: some View {
        if entry.hasData {
            ZStack(alignment: .bottomLeading) {
                // Poster background
                if let poster = entry.posterImage {
                    Image(nsImage: poster)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }

                // Gradient + info
                LinearGradient(
                    colors: [.clear, .black.opacity(0.85)],
                    startPoint: .center,
                    endPoint: .bottom
                )

                VStack(alignment: .leading, spacing: 2) {
                    Spacer()

                    Text("NOW PLAYING")
                        .font(.system(size: 7, weight: .bold))
                        .tracking(1)
                        .foregroundStyle(.orange)

                    Text(entry.movieTitle)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(2)

                    if !entry.movieYear.isEmpty {
                        Text(entry.movieYear)
                            .font(.system(size: 9))
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }
                .padding(10)
            }
        } else {
            VStack(spacing: 6) {
                Image(systemName: "film")
                    .font(.system(size: 24))
                    .foregroundStyle(.tertiary)
                Text("Criterion Now")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.secondary)
                Text("Open app to load")
                    .font(.system(size: 8))
                    .foregroundStyle(.tertiary)
            }
        }
    }
}

struct CriterionWidgetMedium: View {
    let entry: CriterionEntry

    var body: some View {
        if entry.hasData {
            HStack(spacing: 12) {
                // Poster
                if let poster = entry.posterImage {
                    Image(nsImage: poster)
                        .resizable()
                        .aspectRatio(2/3, contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .shadow(color: .black.opacity(0.3), radius: 6, y: 3)
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.quaternary)
                        .aspectRatio(2/3, contentMode: .fit)
                        .overlay {
                            Image(systemName: "film")
                                .foregroundStyle(.tertiary)
                        }
                }

                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text("NOW ON CRITERION 24/7")
                        .font(.system(size: 8, weight: .bold))
                        .tracking(1)
                        .foregroundStyle(.orange)

                    Text(entry.movieTitle)
                        .font(.system(size: 14, weight: .bold))
                        .lineLimit(2)

                    if !entry.director.isEmpty {
                        Text("Dir. \(entry.director)")
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                    }

                    Spacer(minLength: 0)

                    // Progress bar
                    if entry.progress > 0 {
                        VStack(alignment: .leading, spacing: 2) {
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(.quaternary)
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(LinearGradient(colors: [.red, .orange], startPoint: .leading, endPoint: .trailing))
                                        .frame(width: geo.size.width * entry.progress)
                                }
                            }
                            .frame(height: 4)

                            HStack {
                                if !entry.runtime.isEmpty {
                                    Text(entry.runtime)
                                        .font(.system(size: 8, design: .monospaced))
                                        .foregroundStyle(.tertiary)
                                }
                                Spacer()
                                if !entry.nextFilmIn.isEmpty {
                                    Text("Next in \(entry.nextFilmIn)")
                                        .font(.system(size: 8, design: .monospaced))
                                        .foregroundStyle(.tertiary)
                                }
                            }
                        }
                    }
                }
            }
            .padding(12)
        } else {
            emptyState
        }
    }

    private var emptyState: some View {
        HStack(spacing: 12) {
            Image(systemName: "film")
                .font(.system(size: 32))
                .foregroundStyle(.tertiary)
            VStack(alignment: .leading, spacing: 4) {
                Text("Criterion Now")
                    .font(.system(size: 14, weight: .bold))
                Text("Open the app to see what's playing")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(12)
    }
}

// MARK: - Widget Definition

@main
struct CriterionNowWidgetBundle: WidgetBundle {
    var body: some Widget {
        CriterionNowWidget()
    }
}

struct CriterionWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: CriterionEntry

    var body: some View {
        switch family {
        case .systemSmall:
            CriterionWidgetSmall(entry: entry)
        default:
            CriterionWidgetMedium(entry: entry)
        }
    }
}

struct CriterionNowWidget: Widget {
    let kind = "CriterionNowWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CriterionProvider()) { entry in
            CriterionWidgetEntryView(entry: entry)
                .containerBackground(.regularMaterial, for: .widget)
        }
        .configurationDisplayName("Criterion Now")
        .description("What's playing on Criterion 24/7")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
