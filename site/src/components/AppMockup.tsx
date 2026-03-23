import { createSignal, onMount, onCleanup } from "solid-js";

const FILMS = [
  { title: "Mulholland Dr.", director: "David Lynch", year: "2001", runtime: "147 min", country: "USA" },
  { title: "In the Mood for Love", director: "Wong Kar-wai", year: "2000", runtime: "98 min", country: "Hong Kong" },
  { title: "Stalker", director: "Andrei Tarkovsky", year: "1979", runtime: "163 min", country: "USSR" },
  { title: "Paris, Texas", director: "Wim Wenders", year: "1984", runtime: "145 min", country: "Germany" },
  { title: "Persona", director: "Ingmar Bergman", year: "1966", runtime: "83 min", country: "Sweden" },
];

export function AppMockup() {
  const [filmIdx, setFilmIdx] = createSignal(0);
  const [progress, setProgress] = createSignal(0.34);
  const [tab, setTab] = createSignal<"film" | "soundtrack">("film");
  const [elapsed, setElapsed] = createSignal("0:49:12");

  const film = () => FILMS[filmIdx()];

  onMount(() => {
    // Tick progress
    const tick = setInterval(() => {
      setProgress((p) => {
        if (p >= 0.95) return 0.34;
        return p + 0.002;
      });
      // Update elapsed text
      const total = Math.floor(progress() * 147 * 60);
      const h = Math.floor(total / 3600);
      const m = Math.floor((total % 3600) / 60);
      const s = total % 60;
      setElapsed(`${h}:${String(m).padStart(2, "0")}:${String(s).padStart(2, "0")}`);
    }, 100);

    // Cycle films
    const cycle = setInterval(() => {
      setFilmIdx((i) => (i + 1) % FILMS.length);
      setProgress(Math.random() * 0.4 + 0.1);
      setTab("film");
    }, 8000);

    onCleanup(() => {
      clearInterval(tick);
      clearInterval(cycle);
    });
  });

  return (
    <div class="mockup-shell">
      {/* Menu bar */}
      <div class="mockup-menubar">
        <div class="mockup-menubar-left">
          <div class="mockup-apple" />
          <span>Finder</span>
          <span>File</span>
          <span>Edit</span>
          <span>View</span>
        </div>
        <div class="mockup-menubar-right">
          <div class="mockup-tray-icon">
            <svg width="14" height="14" viewBox="0 0 14 14">
              <rect x="1" y="3" width="12" height="8" rx="1.5" fill="none" stroke="currentColor" stroke-width="1.2" />
              <circle cx="7" cy="7" r="2" fill="currentColor" />
            </svg>
            <div class="mockup-streaming-dot" />
          </div>
          <span class="mockup-time">9:41 PM</span>
        </div>
      </div>

      {/* Popover */}
      <div class="mockup-popover">
        {/* Header */}
        <div class="mockup-header">
          <span class="mockup-kicker">NOW ON</span>
          <span class="mockup-title">CRITERION 24/7</span>
        </div>

        {/* Tabs */}
        <div class="mockup-tabs">
          <button
            class={tab() === "film" ? "mockup-tab active" : "mockup-tab"}
            onClick={() => setTab("film")}
          >
            Film
          </button>
          <button
            class={tab() === "soundtrack" ? "mockup-tab active" : "mockup-tab"}
            onClick={() => setTab("soundtrack")}
          >
            Soundtrack
          </button>
        </div>

        {tab() === "film" ? (
          <div class="mockup-film-content">
            {/* Poster placeholder */}
            <div class="mockup-poster">
              <div class="mockup-poster-inner">
                <div class="mockup-poster-grain" />
                <div class="mockup-poster-text">
                  <span class="mockup-poster-title">{film().title}</span>
                  <span class="mockup-poster-sub">{film().year}</span>
                </div>
              </div>
            </div>

            {/* Progress bar */}
            <div class="mockup-progress-wrap">
              <div class="mockup-progress-track">
                <div class="mockup-progress-fill" style={`width: ${progress() * 100}%`} />
              </div>
              <div class="mockup-progress-labels">
                <span>{elapsed()}</span>
                <span>{film().runtime}</span>
              </div>
            </div>

            {/* Film info */}
            <div class="mockup-film-info">
              <span class="mockup-film-title">{film().title}</span>
              <span class="mockup-film-meta">{film().year} · {film().director} · {film().country}</span>
              <span class="mockup-film-runtime">{film().runtime}</span>
            </div>

            {/* Action buttons */}
            <div class="mockup-actions">
              <div class="mockup-action-btn">
                <span>▶</span> Stream
              </div>
              <div class="mockup-action-btn">
                <span>♫</span> Soundtrack
              </div>
              <div class="mockup-action-btn">
                <span>★</span> TMDB
              </div>
            </div>
          </div>
        ) : (
          <div class="mockup-soundtrack-content">
            <div class="mockup-album-art">
              <div class="mockup-vinyl-mini" />
            </div>
            <div class="mockup-album-info">
              <span class="mockup-album-title">Original Soundtrack</span>
              <span class="mockup-album-artist">{film().title} ({film().year})</span>
              <div class="mockup-source-badges">
                <span class="mockup-badge good">Wikidata ✓</span>
                <span class="mockup-badge good">MusicBrainz ✓</span>
                <span class="mockup-badge dim">Discogs</span>
              </div>
            </div>
            <div class="mockup-tracks">
              <div class="mockup-track"><span>01</span> Main Title <span class="mockup-dur">3:42</span></div>
              <div class="mockup-track"><span>02</span> Opening Scene <span class="mockup-dur">2:18</span></div>
              <div class="mockup-track"><span>03</span> Theme <span class="mockup-dur">4:05</span></div>
              <div class="mockup-track"><span>04</span> End Credits <span class="mockup-dur">5:11</span></div>
            </div>
          </div>
        )}

        {/* Bottom bar */}
        <div class="mockup-bottom">
          <div class="mockup-dot books" />
          <div class="mockup-dot clock" />
          <div class="mockup-dot globe" />
          <div class="mockup-bottom-spacer" />
          <span class="mockup-version">v1.0</span>
        </div>
      </div>
    </div>
  );
}
