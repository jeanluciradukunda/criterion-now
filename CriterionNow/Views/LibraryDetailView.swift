import SwiftUI

struct LibraryDetailView: View {
    let movie: LibraryMovie
    let poster: NSImage?
    let soundtrack: SoundtrackAlbum?
    let soundtrackArt: NSImage?
    let isLoading: Bool
    let onBack: () -> Void

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                // Breadcrumb + back
                backBar
                    .padding(.horizontal, 36)
                    .padding(.top, 44)

                // Hero: large poster + info
                heroSection
                    .padding(.horizontal, 36)
                    .padding(.top, 20)
                    .padding(.bottom, 32)

                // Description
                if !movie.overview.isEmpty {
                    descriptionSection
                        .padding(.horizontal, 36)
                        .padding(.bottom, 32)
                }

                // Soundtrack
                if let album = soundtrack {
                    soundtrackSection(album)
                        .padding(.horizontal, 36)
                        .padding(.bottom, 32)
                }

                // Actions
                actionSection
                    .padding(.horizontal, 36)
                    .padding(.bottom, 60)
            }
        }
    }

    // MARK: - Back Bar

    private var backBar: some View {
        HStack(spacing: 6) {
            Button(action: onBack) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 10, weight: .bold))
                    Text("Library")
                        .font(.system(size: 11, weight: .medium))
                }
                .foregroundStyle(.orange)
            }
            .buttonStyle(.plain)

            Text("/")
                .font(.system(size: 11))
                .foregroundStyle(.quaternary)

            Text(movie.title)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.secondary)
                .lineLimit(1)

            Spacer()

            if isLoading {
                ProgressView().scaleEffect(0.5).tint(.orange)
            }
        }
    }

    // MARK: - Hero

    private var heroSection: some View {
        HStack(alignment: .top, spacing: 36) {
            // Large poster with slight tilt (editorial feel)
            if let poster = poster {
                Image(nsImage: poster)
                    .resizable()
                    .aspectRatio(2/3, contentMode: .fit)
                    .frame(maxWidth: 280)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(color: .black.opacity(0.4), radius: 24, y: 12)
                    .rotationEffect(.degrees(-1.5))
            }

            // Film info
            VStack(alignment: .leading, spacing: 16) {
                // Title
                Text(movie.title)
                    .font(.system(size: 34, weight: .bold, design: .serif))
                    .foregroundStyle(.primary)
                    .lineSpacing(2)

                // Metadata row
                HStack(spacing: 10) {
                    if !movie.year.isEmpty {
                        pill(movie.year)
                    }
                    if !movie.runtime.isEmpty {
                        pill(movie.runtime)
                    }
                    if movie.hasSoundtrack {
                        HStack(spacing: 4) {
                            Image(systemName: "music.note")
                                .font(.system(size: 9))
                            Text("Soundtrack")
                                .font(.system(size: 10, weight: .semibold))
                        }
                        .foregroundStyle(.orange)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .background {
                            Capsule()
                                .fill(.orange.opacity(0.12))
                                .overlay {
                                    Capsule().strokeBorder(.orange.opacity(0.25), lineWidth: 0.5)
                                }
                        }
                    }
                }

                // Director
                if !movie.director.isEmpty {
                    HStack(spacing: 0) {
                        Text("Directed by ")
                            .foregroundStyle(.tertiary)
                        Text(movie.director)
                            .foregroundStyle(.primary)
                    }
                    .font(.system(size: 14, weight: .medium))
                }

                // Right-side metadata (like the "files" site)
                VStack(alignment: .leading, spacing: 2) {
                    if !movie.year.isEmpty {
                        Text("Released \(movie.year)")
                            .font(.system(size: 10))
                            .foregroundStyle(.quaternary)
                    }
                }
                .padding(.top, 8)

                Spacer(minLength: 0)
            }
            .padding(.top, 8)
        }
    }

    private func pill(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .semibold))
            .foregroundStyle(.secondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .background(.ultraThinMaterial, in: Capsule())
    }

    // MARK: - Description

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("About")

            // Two-column description like "files"
            HStack(alignment: .top, spacing: 24) {
                let paragraphs = movie.overview.components(separatedBy: "\n").filter { !$0.isEmpty }
                let mid = max(1, paragraphs.count / 2)
                let col1 = paragraphs.prefix(mid).joined(separator: "\n\n")
                let col2 = paragraphs.suffix(from: mid).joined(separator: "\n\n")

                Text(col1)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .lineSpacing(4)
                    .frame(maxWidth: .infinity, alignment: .topLeading)

                if !col2.isEmpty {
                    Text(col2)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .lineSpacing(4)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                }
            }
        }
    }

    // MARK: - Soundtrack

    private func soundtrackSection(_ album: SoundtrackAlbum) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                sectionHeader("Soundtrack")
                Image(systemName: "applelogo")
                    .font(.system(size: 9))
                    .foregroundStyle(.orange)
            }

            HStack(alignment: .top, spacing: 20) {
                // Album art — tilted like a scattered artifact
                if let art = soundtrackArt {
                    Image(nsImage: art)
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .frame(width: 140, height: 140)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .shadow(color: .black.opacity(0.3), radius: 12, y: 6)
                        .rotationEffect(.degrees(2))
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(album.albumName)
                        .font(.system(size: 14, weight: .semibold))
                        .lineLimit(2)

                    Text(album.artistName)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)

                    Text("\(album.tracks.count) tracks")
                        .font(.system(size: 10))
                        .foregroundStyle(.tertiary)

                    Spacer(minLength: 8)

                    // Music service links
                    HStack(spacing: 8) {
                        if let url = album.appleMusicURL {
                            serviceChip(icon: "applelogo", label: "Apple Music", color: .pink) {
                                NSWorkspace.shared.open(url)
                            }
                        }
                        serviceChip(icon: "waveform.circle.fill", label: "Spotify", color: .green) {
                            let q = "\(movie.title) soundtrack".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                            NSWorkspace.shared.open(URL(string: "https://open.spotify.com/search/\(q)")!)
                        }
                        serviceChip(icon: "play.rectangle.fill", label: "YouTube", color: .red) {
                            let q = "\(movie.title) soundtrack".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                            NSWorkspace.shared.open(URL(string: "https://music.youtube.com/search?q=\(q)")!)
                        }
                    }
                }
            }
            .padding(18)
            .background {
                RoundedRectangle(cornerRadius: 14)
                    .fill(.thinMaterial)
                    .shadow(color: .black.opacity(0.08), radius: 8, y: 3)
                    .overlay {
                        RoundedRectangle(cornerRadius: 14)
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
        }
    }

    private func serviceChip(icon: String, label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 3) {
                Image(systemName: icon).font(.system(size: 8))
                Text(label).font(.system(size: 9, weight: .medium))
            }
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.1), in: Capsule())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Actions

    private var actionSection: some View {
        HStack(spacing: 12) {
            filmActionButton(icon: "play.fill", label: "Watch on Criterion", color: .red) {
                NSWorkspace.shared.open(movie.criterionURL)
            }
            filmActionButton(icon: "text.book.closed.fill", label: "Letterboxd", color: .green) {
                NSWorkspace.shared.open(movie.letterboxdURL)
            }
        }
    }

    private func filmActionButton(icon: String, label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon).font(.system(size: 11))
                Text(label).font(.system(size: 12, weight: .medium))
            }
            .foregroundStyle(color)
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(color.opacity(0.1))
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(color.opacity(0.2), lineWidth: 0.5)
                    }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helpers

    private func sectionHeader(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.system(size: 10, weight: .bold))
            .tracking(1.5)
            .foregroundStyle(.tertiary)
    }
}
