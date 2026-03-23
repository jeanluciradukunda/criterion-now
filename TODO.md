# Criterion Now — TODO

## Completed

### Core
- [x] Menu bar popover with Criterion "C" icon (liquid glass)
- [x] Now Playing — poster, progress bar, movie details from TMDB
- [x] Film/Soundtrack tab switcher
- [x] Stream button — WKWebView player with video + radio modes
- [x] Mini player — floating, always-on-top, remembers position, hover controls
- [x] Audio visualizer in radio mode
- [x] Progress bar calculated from TMDB runtime + Criterion countdown
- [x] Action buttons — Stream, Letterboxd, Browse, Copy Title
- [x] Criterion "What's On Now" scraping with HTML typo workaround

### Soundtrack
- [x] 5-source parallel search — Wikidata P406, MusicBrainz, Discogs, iTunes, Last.fm
- [x] Weighted scoring system (6 dimensions, configurable)
- [x] Radar chart visualization of scoring weights
- [x] Composer extraction from TMDB credits
- [x] Album artwork with rounded corners
- [x] Track listings from all sources (including Discogs release endpoint)
- [x] Results shown with confidence score + source attribution
- [x] "No tracks" graceful fallback when art found but no tracklist
- [x] Last.fm scrobbling timed to film progress
- [x] Music service deep links (Apple Music, Spotify, YouTube Music)

### Library
- [x] Scrape Criterion My List via shared WKWebView session
- [x] Collections detected and browsable (nested film lists)
- [x] Inline flip card mode (configurable in settings)
- [x] Full-page scattered poster layout (editorial design)
- [x] TMDB enrichment with strict title matching (Levenshtein)
- [x] Context-aware navigation (Film/Soundtrack tabs follow library focus)
- [x] Persistent local JSON storage (only scrape on explicit refresh)
- [x] Session protection — no scraping while streaming
- [x] Two-finger trackpad swipe + keyboard arrows for navigation

### History
- [x] Automatic film logging on every detected change
- [x] Vertical timeline view with animated glowing spine
- [x] Pulsing dot for currently playing film
- [x] Day grouping headers (Today, Yesterday, dates)
- [x] Slide-in animation for entries
- [x] Mini poster thumbnails per entry
- [x] "NOW" badge on current film
- [x] Stats header (total films, unique directors, days tracked)
- [x] Clock icon toggle in top bar
- [x] Persistent JSON storage

### Notifications
- [x] macOS notifications when new film starts on 24/7
- [x] Poster image attachment
- [x] Auto-detection via 60s timer when film is ending
- [x] Toggle on/off in settings
- [x] Test notification button (uses current film + poster)

### Settings
- [x] Tabbed settings — General, Integrations, Developer
- [x] Developer mode toggle (hidden advanced controls)
- [x] Secure API key storage in macOS Keychain
- [x] Scoring weight sliders with radar chart
- [x] Source trust visualization
- [x] Last.fm connect/disconnect
- [x] All playback, mini player, library, notification toggles

### Performance
- [x] Concurrent TMDB enrichment (5 parallel tasks)
- [x] In-memory caching (TMDB, soundtracks, images)
- [x] Smart Now Playing cache (expires when film ends)
- [x] Soundtrack search results cached
- [x] Library data persisted to disk (no re-scrape needed)
- [x] 5 APIs called in parallel for soundtrack (not cascade)

### Design
- [x] Criterion "C" SVG as app icon (all sizes)
- [x] Liquid glass material throughout
- [x] Orange accent color system
- [x] Quit button in popover

---

## Known Issues

### Library
- Flip card transitions could feel more physical
- Full-page scattered layout needs more editorial polish
- Collection loading shows blank state briefly

### Soundtrack
- Wikidata P406 coverage is sparse for older/obscure films
- MusicBrainz rate limit (1 req/sec) slows track fetching
- Some Discogs results may not be official soundtrack releases
- Scrobbling timed to film progress untested end-to-end

### Streaming
- Volume control can't reach into Vimeo cross-origin iframes
- CSS injection for fullscreen video is fragile
- Multiple device warning from Criterion if session management fails

### History
- Only logs when app is running (misses films while closed)
- No way to manually add/edit/delete entries

---

## Next Up

### High Impact
- **Search** — search library by title, director, year, country, decade
- **Letterboxd integration** — scrape diary/ratings, cross-reference with library
- **Statistics** — director counts, decade distribution, country breakdown
- **"What was on" patterns** — detect themed scheduling after enough data

### Medium Impact
- **Keyboard shortcuts** — global hotkey to open/close popover
- **Director spotlight** — "More by this director" from library
- **Export** — library as CSV, JSON, or Letterboxd import
- **macOS widget** — shows current film (needs Apple Developer signing)

### Nice to Have
- **Trailer playback** — Criterion pages have trailer URLs
- **Share card** — shareable "currently watching" image with poster
- **Companion notes** — personal notes per film
- **Calendar integration** — add scheduled films to calendar

---

## Architecture

### Tech Stack
- Swift / SwiftUI / AppKit (macOS 14+)
- MenuBarExtra with .window style
- WKWebView for streaming + library scraping (single shared session)
- Keychain for API key storage
- Local JSON persistence (~/Library/Application Support/CriterionNow/)
- In-memory caching (CacheService actor)

### External APIs
| API | Purpose | Auth |
|-----|---------|------|
| TMDB | Movie details, posters, credits, composer | Bearer token (Keychain) |
| MusicBrainz | Soundtrack search (type:soundtrack), tracks | User-Agent only |
| Wikidata | Film→soundtrack direct links (P406 SPARQL) | None |
| Discogs | Soundtrack search (style:Soundtrack), tracks | Personal token (Keychain) |
| iTunes | Apple Music album data, track listings | None |
| Last.fm | Scrobbling, album search fallback | API key + secret (Keychain) |
| Criterion | Scraping whatsonnow + My List + collections | WKWebView cookies |

### Key Files
```
CriterionNow/
├── App/
│   └── CriterionNowApp.swift           — Entry point, MenuBarExtra, Keychain bootstrap
├── Models/
│   ├── Movie.swift                      — Now Playing film model (+ composer)
│   ├── LibraryMovie.swift               — Library film model (movies + collections)
│   ├── NowPlayingViewModel.swift        — Stream state, cache, notifications, history logging
│   ├── LibraryViewModel.swift           — Library state, concurrent enrichment, local store
│   ├── HistoryViewModel.swift           — Timeline data, day grouping, stats
│   ├── PlayerManager.swift              — WKWebView streaming, video/radio, volume
│   ├── ScrobbleManager.swift            — Timed Last.fm scrobbling
│   └── SettingsManager.swift            — All @AppStorage settings + scoring weights
├── Services/
│   ├── CriterionService.swift           — Scrapes whatsonnow page
│   ├── CriterionLibraryService.swift    — Scrapes My List + collections
│   ├── TMDBService.swift                — Movie details + credits (cached)
│   ├── SoundtrackService.swift          — 5-source parallel search + weighted scoring
│   ├── LastFMService.swift              — Auth flow + scrobbling (Keychain)
│   ├── HistoryService.swift             — Film history persistence + queries
│   ├── NotificationService.swift        — macOS notifications with poster
│   ├── CacheService.swift               — In-memory caches
│   ├── KeychainService.swift            — Secure API key storage
│   └── LocalStore.swift                 — JSON persistence for library
├── Views/
│   ├── NowPlayingView.swift             — Main popover (tabs, library/history modes)
│   ├── SoundtrackView.swift             — Album art, tracks, music service buttons
│   ├── HistoryView.swift                — Animated vertical timeline
│   ├── InlineLibraryView.swift          — Flip cards with trackpad swipe
│   ├── LibraryView.swift                — Full-page scattered poster grid
│   ├── LibraryDetailView.swift          — Film detail with soundtrack section
│   ├── MiniPlayerWindow.swift           — Floating player window
│   ├── SettingsView.swift               — Tabbed settings (General/Integrations/Developer)
│   ├── RadarChartView.swift             — Scoring weight visualization
│   ├── ActionButton.swift               — Glass hover button component
│   ├── AudioVisualizerView.swift        — Animated equalizer bars
│   ├── PinButton.swift                  — Pin toggle
│   ├── PlayerControlsView.swift         — Volume, radio, dock controls
│   ├── StreamWebView.swift              — WKWebView wrapper
│   ├── SettingsWindow.swift             — Settings NSWindow controller
│   └── LibraryWindow.swift              — Library NSWindow controller
└── Resources/
    ├── Assets.xcassets/                 — Criterion C icon (all sizes), menu bar template
    └── CriterionNow.entitlements        — Sandbox + network
```
