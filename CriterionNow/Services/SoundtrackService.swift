import Foundation

// MARK: - Models

enum SoundtrackSource: String {
    case wikidata = "wikidata"
    case musicbrainz = "musicbrainz"
    case discogs = "discogs"
    case apple = "apple"
    case lastfm = "lastfm"

    var iconName: String {
        switch self {
        case .wikidata: return "globe"
        case .musicbrainz: return "music.note.list"
        case .discogs: return "opticaldisc.fill"
        case .apple: return "applelogo"
        case .lastfm: return "music.note.tv"
        }
    }

    var label: String {
        switch self {
        case .wikidata: return "Wikidata"
        case .musicbrainz: return "MusicBrainz"
        case .discogs: return "Discogs"
        case .apple: return "Apple Music"
        case .lastfm: return "Last.fm"
        }
    }

    /// Source trust weight (0-15)
    var trustScore: Double {
        switch self {
        case .wikidata: return 15    // Curated human-linked data
        case .musicbrainz: return 12 // type:soundtrack filter
        case .discogs: return 11     // style:Soundtrack filter, great catalog
        case .apple: return 8        // General search, decent catalog
        case .lastfm: return 5       // Weakest catalog for soundtracks
        }
    }
}

struct SoundtrackAlbum {
    let albumName: String
    let artistName: String
    let artworkURL: URL?
    let allArtworkURLs: [URL]    // all covers (front, back, inserts) — mainly from Discogs
    let tracks: [SoundtrackTrack]
    let appleMusicURL: URL?
    let lastfmURL: URL?
    let musicbrainzURL: URL?
    let source: SoundtrackSource
    let confidenceScore: Double // 0-100
    let releaseYear: Int?       // actual release year from source metadata
}

struct SoundtrackTrack {
    let name: String
    let artistName: String
    let durationMs: Int
    let trackNumber: Int
    let previewURL: URL?

    var durationFormatted: String {
        let totalSeconds = durationMs / 1000
        return String(format: "%d:%02d", totalSeconds / 60, totalSeconds % 60)
    }
}

/// A candidate result from any source, before scoring
private struct SoundtrackCandidate {
    let album: SoundtrackAlbum
    let source: SoundtrackSource
    var score: Double = 0
}

// MARK: - Scoring Context

struct SoundtrackSearchContext {
    let movieTitle: String
    let year: String
    let composer: String
    let director: String

    // Scoring weights (configurable from developer settings)
    var weightTitle: Double = 30
    var weightKeywords: Double = 20
    var weightComposer: Double = 25
    var weightYear: Double = 10
    var weightSource: Double = 15
    var weightContent: Double = 5
    var minThreshold: Double = 40

    var cleanTitle: String {
        movieTitle.replacingOccurrences(of: #"\s+\d{4}$"#, with: "", options: .regularExpression)
    }
}

// MARK: - iTunes API Response Models

private struct iTunesSearchResponse: Codable {
    let resultCount: Int
    let results: [iTunesAlbumResult]
}

private struct iTunesAlbumResult: Codable {
    let collectionId: Int
    let collectionName: String
    let artistName: String
    let artworkUrl100: String?
    let collectionViewUrl: String?
    let releaseDate: String?
}

private struct iTunesLookupResponse: Codable {
    let resultCount: Int
    let results: [iTunesLookupResult]
}

private struct iTunesLookupResult: Codable {
    let wrapperType: String?
    let trackName: String?
    let artistName: String?
    let trackTimeMillis: Int?
    let trackNumber: Int?
    let previewUrl: String?
}

// MARK: - Service

actor SoundtrackService {
    enum SoundtrackError: LocalizedError {
        case notFound
        var errorDescription: String? { "No soundtrack found" }
    }

    private var lastfmApiKey: String { KeychainService.lastfmApiKey }
    private let mbUserAgent = "CriterionNow/1.0 (https://github.com/jeanluciradukunda/criterion-now)"
    private var discogsToken: String { KeychainService.discogsToken }
    private let cache = CacheService.shared

    // MARK: - Main Search (Parallel + Weighted Scoring)

    struct ScoringWeights {
        var title: Double = 30
        var keywords: Double = 20
        var composer: Double = 25
        var year: Double = 10
        var source: Double = 15
        var content: Double = 5
        var threshold: Double = 40
    }

    /// Returns the best result (backwards compatible)
    func searchSoundtrack(movieTitle: String, composer: String = "", year: String = "", director: String = "", weights: ScoringWeights = ScoringWeights()) async throws -> SoundtrackAlbum {
        let results = try await searchSoundtrackAll(movieTitle: movieTitle, composer: composer, year: year, director: director, weights: weights)
        guard let best = results.first else { throw SoundtrackError.notFound }
        return best
    }

    /// Returns ALL results above threshold, deduplicated, sorted by score (for carousel)
    func searchSoundtrackAll(movieTitle: String, composer: String = "", year: String = "", director: String = "", weights: ScoringWeights = ScoringWeights()) async throws -> [SoundtrackAlbum] {
        if let cached = await cache.getCachedSoundtrack(title: movieTitle) {
            return [cached]
        }

        var ctx = SoundtrackSearchContext(movieTitle: movieTitle, year: year, composer: composer, director: director)
        ctx.weightTitle = weights.title
        ctx.weightKeywords = weights.keywords
        ctx.weightComposer = weights.composer
        ctx.weightYear = weights.year
        ctx.weightSource = weights.source
        ctx.weightContent = weights.content
        ctx.minThreshold = weights.threshold

        // If no composer, redistribute weight to title + keywords
        if composer.isEmpty {
            ctx.weightTitle += ctx.weightComposer * 0.6
            ctx.weightKeywords += ctx.weightComposer * 0.4
            ctx.weightComposer = 0
        }

        async let wd = fetchWikidata(ctx: ctx)
        async let mb = fetchMusicBrainz(ctx: ctx)
        async let dc = fetchDiscogs(ctx: ctx)
        async let it = fetchItunes(ctx: ctx)
        async let lf = fetchLastFM(ctx: ctx)

        var candidates: [SoundtrackCandidate] = []
        if let r = try? await wd { candidates.append(contentsOf: r) }
        if let r = try? await mb { candidates.append(contentsOf: r) }
        if let r = try? await dc { candidates.append(contentsOf: r) }
        if let r = try? await it { candidates.append(contentsOf: r) }
        if let r = try? await lf { candidates.append(contentsOf: r) }

        let scored = candidates.map { score(candidate: $0, ctx: ctx) }
        let passing = scored.filter { $0.score >= ctx.minThreshold }
        guard !passing.isEmpty else { throw SoundtrackError.notFound }

        // Deduplicate by normalized album name — keep highest score
        var deduped: [String: SoundtrackCandidate] = [:]
        for c in passing {
            let key = normalizeForDedup(c.album.albumName)
            if let ex = deduped[key] { if c.score > ex.score { deduped[key] = c } }
            else { deduped[key] = c }
        }

        let results = Array(deduped.values.sorted { $0.score > $1.score }.prefix(5).map { c in
            SoundtrackAlbum(albumName: c.album.albumName, artistName: c.album.artistName,
                artworkURL: c.album.artworkURL, allArtworkURLs: c.album.allArtworkURLs, tracks: c.album.tracks,
                appleMusicURL: c.album.appleMusicURL, lastfmURL: c.album.lastfmURL,
                musicbrainzURL: c.album.musicbrainzURL, source: c.source, confidenceScore: c.score, releaseYear: c.album.releaseYear)
        })

        if let best = results.first { await cache.cacheSoundtrack(title: movieTitle, album: best) }
        return results
    }

    private func normalizeForDedup(_ name: String) -> String {
        name.lowercased()
            .replacingOccurrences(of: #"\s*\(.*\)"#, with: "", options: .regularExpression)
            .replacingOccurrences(of: #"[^a-z0-9]"#, with: "", options: .regularExpression)
    }

    private func normalizeTitle(_ s: String) -> String {
        var t = s.lowercased().folding(options: .diacriticInsensitive, locale: .current)
        for a in ["the ", "a ", "an ", "le ", "la ", "les ", "l'", "el ", "il ", "das ", "der ", "die "] {
            if t.hasPrefix(a) { t = String(t.dropFirst(a.count)) }
        }
        for sfx in [" (original motion picture soundtrack)", " (original soundtrack)", " soundtrack", " ost", " - original score"] {
            if t.hasSuffix(sfx) { t = String(t.dropLast(sfx.count)) }
        }
        return t.replacingOccurrences(of: #"[^\w\s]"#, with: "", options: .regularExpression).trimmingCharacters(in: .whitespaces)
    }

    // MARK: - Improved Scoring

    private func score(candidate: SoundtrackCandidate, ctx: SoundtrackSearchContext) -> SoundtrackCandidate {
        var c = candidate
        var total: Double = 0
        let albumNorm = normalizeTitle(c.album.albumName)
        let titleNorm = normalizeTitle(ctx.cleanTitle)
        let albumLower = c.album.albumName.lowercased()
        let artistLower = c.album.artistName.lowercased()
        let wT = ctx.weightTitle, wK = ctx.weightKeywords, wC = ctx.weightComposer
        let wY = ctx.weightYear, wS = ctx.weightSource, wCo = ctx.weightContent

        // 1. Title (accent/article insensitive, strict contains check)
        let titleSim = fuzzyMatch(albumNorm, titleNorm)
        if albumNorm == titleNorm {
            total += wT
        } else if titleSim > 0.85 {
            // Very close fuzzy match (handles minor variations)
            total += wT * 0.9
        } else if albumNorm.contains(titleNorm) && titleNorm.count >= 4 &&
                  Double(titleNorm.count) / Double(max(albumNorm.count, 1)) > 0.5 {
            // Title is a substantial part of album name (not just a short substring)
            total += wT * 0.67
        } else if titleNorm.contains(albumNorm) && albumNorm.count >= 4 &&
                  Double(albumNorm.count) / Double(max(titleNorm.count, 1)) > 0.5 {
            // Album name is a substantial part of title
            total += wT * 0.67
        } else if titleSim > 0.7 {
            total += wT * 0.33
        }

        // 2. Keywords (penalize compilations, tributes, covers)
        let strong = ["soundtrack", "score", "motion picture", "original score", "film music", "bande originale"]
        let negFlags = ["greatest", "best of", "vol.", "volume", "collection", "hits",
                        "tribute", "cover", "karaoke", "inspired by", "reimagined",
                        "piano version", "lullaby", "for babies", "8-bit"]
        let isNeg = negFlags.contains(where: { albumLower.contains($0) })
        if isNeg {
            if strong.contains(where: { albumLower.contains($0) }) { total += wK * 0.2 }
        } else if strong.contains(where: { albumLower.contains($0) }) { total += wK }
        else if albumLower.contains("original") { total += wK * 0.5 }

        // 3. Composer (weight is 0 if no composer — already redistributed)
        if wC > 0 && !ctx.composer.isEmpty {
            let cn = normalizeTitle(ctx.composer), an = normalizeTitle(c.album.artistName)
            if an.contains(cn) || cn.contains(an) { total += wC }
            else if fuzzyMatch(an, cn) > 0.6 { total += wC * 0.6 }
            if artistLower.contains("various") && strong.contains(where: { albumLower.contains($0) }) { total += wC * 0.3 }
        }
        if !ctx.director.isEmpty && artistLower.contains(normalizeTitle(ctx.director)) { total += min(wC, 10) * 0.4 }

        // 4. Year (use source release year if available, fall back to text extraction)
        if !ctx.year.isEmpty, let my = Int(ctx.year) {
            let ay = c.album.releaseYear ?? extractYear(from: c.album.albumName) ?? extractYear(from: c.album.artistName)
            if let ay = ay {
                let d = abs(my - ay)
                if d == 0 { total += wY } else if d <= 2 { total += wY * 0.7 } else if d <= 5 { total += wY * 0.3 }
            }
        }

        // 5. Source trust (MULTIPLICATIVE — amplifies good matches, penalizes bad ones)
        let contentScore = total // score so far from content dimensions
        let trustMultiplier = 0.7 + (c.source.trustScore / 15.0) * 0.3 // 0.7 to 1.0 range
        total = contentScore * trustMultiplier
        // Add small additive bonus so trusted sources still get a slight edge
        total += (c.source.trustScore / 15.0) * (wS * 0.3)


        // 6. Content completeness
        if c.album.artworkURL != nil { total += wCo * 0.4 }
        if !c.album.tracks.isEmpty { total += wCo * 0.6 }

        c.score = min(100, total)
        return c
    }


    private func fuzzyMatch(_ a: String, _ b: String) -> Double {
        if a.isEmpty || b.isEmpty { return 0 }
        let aChars = Array(a), bChars = Array(b)
        let aLen = aChars.count, bLen = bChars.count
        var matrix = [[Int]](repeating: [Int](repeating: 0, count: bLen + 1), count: aLen + 1)
        for i in 0...aLen { matrix[i][0] = i }
        for j in 0...bLen { matrix[0][j] = j }
        for i in 1...aLen {
            for j in 1...bLen {
                let cost = aChars[i-1] == bChars[j-1] ? 0 : 1
                matrix[i][j] = min(matrix[i-1][j]+1, matrix[i][j-1]+1, matrix[i-1][j-1]+cost)
            }
        }
        return 1.0 - Double(matrix[aLen][bLen]) / Double(max(aLen, bLen))
    }

    private func extractYear(from text: String) -> Int? {
        let range = text.range(of: #"\b(19|20)\d{2}\b"#, options: .regularExpression)
        guard let range = range else { return nil }
        return Int(text[range])
    }

    // MARK: - Source: Wikidata (P406)

    private func fetchWikidata(ctx: SoundtrackSearchContext) async throws -> [SoundtrackCandidate] {
        let sparql = """
        SELECT ?soundtrack ?soundtrackLabel ?mbid WHERE {
          ?film rdfs:label "\(ctx.cleanTitle)"@en ;
                wdt:P31/wdt:P279* wd:Q11424 ;
                wdt:P406 ?soundtrack .
          OPTIONAL { ?soundtrack wdt:P436 ?mbid . }
          SERVICE wikibase:label { bd:serviceParam wikibase:language "en" . }
        } LIMIT 3
        """
        let encoded = sparql.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let url = URL(string: "https://query.wikidata.org/sparql?format=json&query=\(encoded)")!

        var request = URLRequest(url: url)
        request.setValue("CriterionNow/1.0", forHTTPHeaderField: "User-Agent")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, _) = try await URLSession.shared.data(for: request)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        guard let results = json?["results"] as? [String: Any],
              let bindings = results["bindings"] as? [[String: Any]] else { return [] }

        var candidates: [SoundtrackCandidate] = []
        for binding in bindings {
            let label = (binding["soundtrackLabel"] as? [String: Any])?["value"] as? String ?? ""
            let mbid = (binding["mbid"] as? [String: Any])?["value"] as? String

            var artworkURL: URL?
            var mbURL: URL?
            var tracks: [SoundtrackTrack] = []

            if let mbid = mbid {
                artworkURL = URL(string: "https://coverartarchive.org/release-group/\(mbid)/front-500")
                mbURL = URL(string: "https://musicbrainz.org/release-group/\(mbid)")
                tracks = (try? await fetchMBTracks(releaseGroupId: mbid)) ?? []
            }

            let album = SoundtrackAlbum(
                albumName: label, artistName: "Various Artists", artworkURL: artworkURL, allArtworkURLs: [],
                tracks: tracks, appleMusicURL: nil, lastfmURL: nil, musicbrainzURL: mbURL,
                source: .wikidata, confidenceScore: 0, releaseYear: nil
            )
            candidates.append(SoundtrackCandidate(album: album, source: .wikidata))
        }
        return candidates
    }

    // MARK: - Source: MusicBrainz

    private func fetchMusicBrainz(ctx: SoundtrackSearchContext) async throws -> [SoundtrackCandidate] {
        let titleEnc = ctx.cleanTitle.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let url = URL(string: "https://musicbrainz.org/ws/2/release-group/?query=\(titleEnc) AND type:soundtrack&fmt=json&limit=5")!

        var request = URLRequest(url: url)
        request.setValue(mbUserAgent, forHTTPHeaderField: "User-Agent")

        let (data, _) = try await URLSession.shared.data(for: request)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let releaseGroups = json?["release-groups"] as? [[String: Any]] ?? []

        var candidates: [SoundtrackCandidate] = []
        for rg in releaseGroups.prefix(3) {
            let rgTitle = rg["title"] as? String ?? ""
            let rgId = rg["id"] as? String ?? ""
            let artists = rg["artist-credit"] as? [[String: Any]] ?? []
            let artist = artists.first.flatMap { ($0["name"] as? String) ?? ($0["artist"] as? [String: Any])?["name"] as? String } ?? "Various Artists"

            let artworkURL = URL(string: "https://coverartarchive.org/release-group/\(rgId)/front-500")
            let mbURL = URL(string: "https://musicbrainz.org/release-group/\(rgId)")

            let album = SoundtrackAlbum(
                albumName: rgTitle, artistName: artist, artworkURL: artworkURL, allArtworkURLs: [],
                tracks: [], appleMusicURL: nil, lastfmURL: nil, musicbrainzURL: mbURL,
                source: .musicbrainz, confidenceScore: 0, releaseYear: nil
            )
            candidates.append(SoundtrackCandidate(album: album, source: .musicbrainz))
        }
        return candidates
    }

    // MARK: - Source: iTunes

    private func fetchItunes(ctx: SoundtrackSearchContext) async throws -> [SoundtrackCandidate] {
        let queries = ["\(ctx.cleanTitle) original soundtrack", "\(ctx.cleanTitle) soundtrack"]
        var candidates: [SoundtrackCandidate] = []

        for query in queries {
            let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            let url = URL(string: "https://itunes.apple.com/search?term=\(encoded)&entity=album&limit=3")!

            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(iTunesSearchResponse.self, from: data)

            for result in response.results.prefix(2) {
                let artworkURL = result.artworkUrl100.flatMap { URL(string: $0.replacingOccurrences(of: "100x100", with: "600x600")) }
                let appleMusicURL = result.collectionViewUrl.flatMap { URL(string: $0) }

                let album = SoundtrackAlbum(
                    albumName: result.collectionName, artistName: result.artistName,
                    artworkURL: artworkURL, allArtworkURLs: [], tracks: [],
                    appleMusicURL: appleMusicURL, lastfmURL: nil, musicbrainzURL: nil,
                    source: .apple, confidenceScore: 0, releaseYear: nil
                )
                candidates.append(SoundtrackCandidate(album: album, source: .apple))
            }
        }
        return candidates
    }

    // MARK: - Source: Last.fm

    private func fetchLastFM(ctx: SoundtrackSearchContext) async throws -> [SoundtrackCandidate] {
        let query = "\(ctx.cleanTitle) soundtrack".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let url = URL(string: "https://ws.audioscrobbler.com/2.0/?method=album.search&album=\(query)&api_key=\(lastfmApiKey)&format=json&limit=3")!

        let (data, _) = try await URLSession.shared.data(from: url)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        guard let results = json?["results"] as? [String: Any],
              let matches = results["albummatches"] as? [String: Any],
              let albums = matches["album"] as? [[String: Any]] else { return [] }

        var candidates: [SoundtrackCandidate] = []
        for albumData in albums.prefix(2) {
            let name = albumData["name"] as? String ?? ""
            let artist = albumData["artist"] as? String ?? ""

            var artworkURL: URL?
            if let images = albumData["image"] as? [[String: Any]] {
                for img in images.reversed() {
                    if let urlStr = img["#text"] as? String, !urlStr.isEmpty {
                        artworkURL = URL(string: urlStr); break
                    }
                }
            }

            let lastfmURL = (albumData["url"] as? String).flatMap { URL(string: $0) }

            let album = SoundtrackAlbum(
                albumName: name, artistName: artist, artworkURL: artworkURL, allArtworkURLs: [],
                tracks: [], appleMusicURL: nil, lastfmURL: lastfmURL, musicbrainzURL: nil,
                source: .lastfm, confidenceScore: 0, releaseYear: nil
            )
            candidates.append(SoundtrackCandidate(album: album, source: .lastfm))
        }
        return candidates
    }

    // MARK: - Source: Discogs (style:Soundtrack filter)

    private func fetchDiscogs(ctx: SoundtrackSearchContext) async throws -> [SoundtrackCandidate] {
        let query = ctx.cleanTitle.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let url = URL(string: "https://api.discogs.com/database/search?q=\(query)&type=release&style=Soundtrack&per_page=5&token=\(discogsToken)")!

        var request = URLRequest(url: url)
        request.setValue("CriterionNow/1.0", forHTTPHeaderField: "User-Agent")

        let (data, _) = try await URLSession.shared.data(for: request)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let results = json?["results"] as? [[String: Any]] ?? []

        var candidates: [SoundtrackCandidate] = []
        for result in results.prefix(3) {
            let title = result["title"] as? String ?? ""
            let parts = title.components(separatedBy: " - ")
            let artist = parts.count > 1 ? parts[0].trimmingCharacters(in: .whitespaces) : "Various"
            let albumName = parts.count > 1 ? parts[1...].joined(separator: " - ").trimmingCharacters(in: .whitespaces) : title

            let coverURL = (result["cover_image"] as? String).flatMap { URL(string: $0) }
            let thumbURL = (result["thumb"] as? String).flatMap { URL(string: $0) }

            let discogsId = result["id"] as? Int ?? 0
            let discogsWebURL = URL(string: "https://www.discogs.com/release/\(discogsId)")
            let resourceURL = result["resource_url"] as? String

            // Fetch tracks + all cover images from the release detail
            var tracks: [SoundtrackTrack] = []
            var allImages: [URL] = []
            if let resourceURL = resourceURL {
                let release = try? await fetchDiscogsRelease(resourceURL: resourceURL)
                tracks = release?.tracks ?? []
                allImages = release?.imageURLs ?? []
            }

            let album = SoundtrackAlbum(
                albumName: albumName,
                artistName: artist,
                artworkURL: allImages.first ?? coverURL ?? thumbURL,
                allArtworkURLs: allImages,
                tracks: tracks,
                appleMusicURL: nil,
                lastfmURL: nil,
                musicbrainzURL: discogsWebURL,
                source: .discogs,
                confidenceScore: 0, releaseYear: nil
            )
            candidates.append(SoundtrackCandidate(album: album, source: .discogs))
        }
        return candidates
    }

    /// Fetches tracks AND all cover images from a Discogs release
    private func fetchDiscogsRelease(resourceURL: String) async throws -> (tracks: [SoundtrackTrack], imageURLs: [URL]) {
        let url = URL(string: "\(resourceURL)?token=\(discogsToken)")!
        var request = URLRequest(url: url)
        request.setValue("CriterionNow/1.0", forHTTPHeaderField: "User-Agent")

        let (data, _) = try await URLSession.shared.data(for: request)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        // Extract all images
        var imageURLs: [URL] = []
        if let images = json?["images"] as? [[String: Any]] {
            for img in images {
                if let uri = img["uri"] as? String, let imgURL = URL(string: uri) {
                    imageURLs.append(imgURL)
                }
            }
        }

        guard let tracklist = json?["tracklist"] as? [[String: Any]] else { return ([], imageURLs) }

        var tracks: [SoundtrackTrack] = []
        for (index, t) in tracklist.enumerated() {
            let title = t["title"] as? String ?? ""
            let position = t["position"] as? String ?? "\(index + 1)"
            let durationStr = t["duration"] as? String ?? ""

            // Parse duration "M:SS" or "MM:SS" to milliseconds
            let durationMs = parseDuration(durationStr)

            // Get artist — either from extraartists or track-level artists
            var artist = ""
            if let artists = t["artists"] as? [[String: Any]], let first = artists.first {
                artist = first["name"] as? String ?? ""
            }

            if !title.isEmpty {
                tracks.append(SoundtrackTrack(
                    name: title,
                    artistName: artist,
                    durationMs: durationMs,
                    trackNumber: index + 1,
                    previewURL: nil
                ))
            }
        }
        return (tracks, imageURLs)
    }

    // Legacy wrapper for non-Discogs callers
    private func fetchDiscogsTracks(resourceURL: String) async throws -> [SoundtrackTrack] {
        let (tracks, _) = try await fetchDiscogsRelease(resourceURL: resourceURL)
        return tracks
    }

    private func parseDuration(_ str: String) -> Int {
        // Parse "3:45" or "12:03" to milliseconds
        let parts = str.components(separatedBy: ":")
        guard parts.count == 2,
              let minutes = Int(parts[0]),
              let seconds = Int(parts[1]) else { return 0 }
        return (minutes * 60 + seconds) * 1000
    }

    // MARK: - MusicBrainz Track Fetcher

    private func fetchMBTracks(releaseGroupId: String) async throws -> [SoundtrackTrack] {
        try await Task.sleep(nanoseconds: 1_100_000_000)

        let rgURL = URL(string: "https://musicbrainz.org/ws/2/release-group/\(releaseGroupId)?inc=releases&fmt=json")!
        var req1 = URLRequest(url: rgURL)
        req1.setValue(mbUserAgent, forHTTPHeaderField: "User-Agent")
        let (data1, _) = try await URLSession.shared.data(for: req1)
        let rgJSON = try JSONSerialization.jsonObject(with: data1) as? [String: Any]

        guard let releases = rgJSON?["releases"] as? [[String: Any]],
              let releaseId = releases.first?["id"] as? String else { return [] }

        try await Task.sleep(nanoseconds: 1_100_000_000)

        let tURL = URL(string: "https://musicbrainz.org/ws/2/release/\(releaseId)?inc=recordings&fmt=json")!
        var req2 = URLRequest(url: tURL)
        req2.setValue(mbUserAgent, forHTTPHeaderField: "User-Agent")
        let (data2, _) = try await URLSession.shared.data(for: req2)
        let rJSON = try JSONSerialization.jsonObject(with: data2) as? [String: Any]

        var tracks: [SoundtrackTrack] = []
        for medium in (rJSON?["media"] as? [[String: Any]]) ?? [] {
            for t in (medium["tracks"] as? [[String: Any]]) ?? [] {
                let title = t["title"] as? String ?? ""
                let pos = t["position"] as? Int ?? (tracks.count + 1)
                let len = t["length"] as? Int ?? 0
                let artist = ((t["recording"] as? [String: Any])?["artist-credit"] as? [[String: Any]])?.first?["name"] as? String ?? "Unknown"
                if !title.isEmpty {
                    tracks.append(SoundtrackTrack(name: title, artistName: artist, durationMs: len, trackNumber: pos, previewURL: nil))
                }
            }
        }
        return tracks.sorted { $0.trackNumber < $1.trackNumber }
    }

    // MARK: - External URLs

    func spotifySearchURL(movieTitle: String) -> URL {
        let q = "\(movieTitle) soundtrack".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return URL(string: "https://open.spotify.com/search/\(q)")!
    }

    func youTubeMusicSearchURL(movieTitle: String) -> URL {
        let q = "\(movieTitle) soundtrack".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return URL(string: "https://music.youtube.com/search?q=\(q)")!
    }
}
