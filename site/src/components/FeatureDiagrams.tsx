/** Isometric animated technical diagrams — makingsoftware.com inspired */

const C = "#e6dbc8";
const INK = "#1a1613";
const RED = "#c0392b";
const OX = "#8b2017";
const BRK = "#d45a3b";
const SAL = "#e8a090";
const GLD = "#d4a843";
const MID = "#6b5e52";
const MUT = "#9c8e7e";
const PAP = "#f5f0e8";

/* Isometric helper: transforms a flat group into isometric view */
const ISO = "skewY(-30) scaleX(0.866)";
const ISO_R = "skewY(30) scaleX(0.866)";

/** 1. NOW PLAYING — isometric popover with data flow */
export function NowPlayingDiagram() {
  return (
    <svg viewBox="0 0 400 340" fill="none" xmlns="http://www.w3.org/2000/svg">
      <style>{`
        @keyframes pulse-bar { 0%,100% { width: 120px; } 50% { width: 135px; } }
        @keyframes data-flow { 0% { opacity: 0; transform: translateY(8px); } 50% { opacity: 1; } 100% { opacity: 0; transform: translateY(-8px); } }
        @keyframes tick { 0%,100% { opacity: 1; } 50% { opacity: 0.3; } }
        .flow-dot { animation: data-flow 2s ease-in-out infinite; }
        .flow-dot2 { animation: data-flow 2s ease-in-out 0.7s infinite; }
        .flow-dot3 { animation: data-flow 2s ease-in-out 1.4s infinite; }
        .tick-blink { animation: tick 1s steps(1) infinite; }
      `}</style>

      {/* Isometric menu bar */}
      <g transform="translate(80, 30)">
        <g transform={ISO}>
          <rect width="240" height="16" rx="3" fill={INK} />
          <rect x="200" y="2" width="28" height="12" rx="2" fill={GLD} opacity="0.9" />
          <text x="208" y="11" font-family="Departure Mono, monospace" font-size="7" fill={INK} font-weight="bold">C</text>
        </g>
      </g>

      {/* Isometric popover card */}
      <g transform="translate(60, 65)">
        {/* Left face */}
        <g transform={ISO}>
          <rect width="200" height="220" rx="8" fill={PAP} stroke={MID} stroke-width="0.5" />
          {/* Poster */}
          <rect x="16" y="16" width="80" height="110" rx="4" fill={BRK} opacity="0.7" />
          <rect x="18" y="18" width="76" height="106" rx="3" fill={SAL} opacity="0.3" />
          <text x="30" y="72" font-family="Departure Mono, monospace" font-size="8" fill={C}>POSTER</text>

          {/* Info */}
          <text x="108" y="32" font-family="Departure Mono, monospace" font-size="7" fill={INK}>Belle de Jour</text>
          <text x="108" y="44" font-family="Departure Mono, monospace" font-size="6" fill={MUT}>1967 · Buñuel</text>
          <text x="108" y="56" font-family="Departure Mono, monospace" font-size="6" fill={MUT}>101 min</text>

          {/* Progress bar */}
          <rect x="16" y="140" width="168" height="6" rx="2" fill={INK} opacity="0.1" />
          <rect x="16" y="140" width="112" height="6" rx="2" fill={RED}>
            <animate attributeName="width" values="100;120;100" dur="4s" repeatCount="indefinite" />
          </rect>

          <text x="16" y="158" font-family="Departure Mono, monospace" font-size="5" fill={MUT}>67 of 101 min</text>
          <text x="148" y="158" font-family="Departure Mono, monospace" font-size="5" fill={RED} class="tick-blink">66%</text>

          {/* Timer indicator */}
          <rect x="16" y="170" width="168" height="16" rx="3" fill={INK} opacity="0.04" />
          <text x="20" y="181" font-family="Departure Mono, monospace" font-size="5" fill={RED}>⏱ 1s ticker</text>
          <text x="120" y="181" font-family="Departure Mono, monospace" font-size="5" fill={MUT}>34m 12s left</text>

          {/* Tabs */}
          <rect x="16" y="194" width="50" height="14" rx="3" fill={GLD} opacity="0.6" />
          <text x="24" y="204" font-family="Departure Mono, monospace" font-size="5" fill={INK}>Film</text>
          <rect x="70" y="194" width="70" height="14" rx="3" fill={INK} opacity="0.05" />
          <text x="76" y="204" font-family="Departure Mono, monospace" font-size="5" fill={MUT}>Soundtrack</text>
        </g>
      </g>

      {/* Data flow arrows */}
      {/* From Criterion */}
      <circle cx="30" cy="120" r="3" fill={GLD} class="flow-dot" />
      <circle cx="30" cy="135" r="3" fill={GLD} class="flow-dot2" />
      <line x1="36" y1="130" x2="58" y2="130" stroke={GLD} stroke-width="0.5" stroke-dasharray="3 2" />
      <text x="4" y="110" font-family="Departure Mono, monospace" font-size="6" fill={GLD}>Criterion</text>

      {/* From TMDB */}
      <circle cx="310" cy="100" r="3" fill={BRK} class="flow-dot3" />
      <circle cx="310" cy="115" r="3" fill={BRK} class="flow-dot" />
      <line x1="270" y1="110" x2="308" y2="110" stroke={BRK} stroke-width="0.5" stroke-dasharray="3 2" />
      <text x="314" y="100" font-family="Departure Mono, monospace" font-size="6" fill={BRK}>TMDB</text>
      <text x="314" y="110" font-family="Departure Mono, monospace" font-size="5" fill={MUT}>poster</text>
      <text x="314" y="118" font-family="Departure Mono, monospace" font-size="5" fill={MUT}>credits</text>
    </svg>
  );
}

/** 2. SOUNDTRACK — isometric scoring pipeline */
export function SoundtrackDiagram() {
  const sources = [
    { name: "Wikidata", score: 92, color: GLD, pass: true },
    { name: "MusicBrainz", score: 87, color: BRK, pass: true },
    { name: "Discogs", score: 74, color: SAL, pass: true },
    { name: "iTunes", score: 38, color: MUT, pass: false },
    { name: "Last.fm", score: 22, color: MUT, pass: false },
  ];

  return (
    <svg viewBox="0 0 400 300" fill="none" xmlns="http://www.w3.org/2000/svg">
      <style>{`
        @keyframes scan { 0% { transform: translateX(0); } 100% { transform: translateX(180px); } }
        @keyframes fade-in { 0% { opacity: 0; } 100% { opacity: 1; } }
        .scan-line { animation: scan 3s linear infinite; }
      `}</style>

      {/* Input: film title */}
      <g transform="translate(20, 20)">
        <g transform={ISO}>
          <rect width="100" height="30" rx="4" fill={INK} />
          <text x="10" y="19" font-family="Departure Mono, monospace" font-size="7" fill={C}>Film Title →</text>
        </g>
      </g>

      {/* Parallel lanes — isometric stacked */}
      {sources.map((s, i) => (
        <g transform={`translate(40, ${70 + i * 38})`}>
          <g transform={ISO}>
            {/* Lane background */}
            <rect width="200" height="24" rx="3" fill={s.pass ? PAP : INK} opacity={s.pass ? 1 : 0.05} stroke={s.pass ? s.color : MUT} stroke-width="0.5" />
            {/* Score bar */}
            <rect x="2" y="2" width={s.score * 1.9} height="20" rx="2" fill={s.color} opacity={s.pass ? 0.6 : 0.15}>
              <animate attributeName="width" from="0" to={s.score * 1.9} dur="1.5s" fill="freeze" begin={`${i * 0.2}s`} />
            </rect>
            {/* Label */}
            <text x="8" y="16" font-family="Departure Mono, monospace" font-size="6" fill={s.pass ? INK : MUT}>{s.name}</text>
          </g>
          {/* Score callout */}
          <text x="220" y="10" font-family="Departure Mono, monospace" font-size="8" fill={s.pass ? s.color : MUT} font-weight={s.pass ? "bold" : "normal"}>{s.score}</text>
          {s.pass && <text x="240" y="10" font-family="Departure Mono, monospace" font-size="6" fill={GLD}>✓</text>}
          {!s.pass && <text x="240" y="10" font-family="Departure Mono, monospace" font-size="6" fill={MUT}>✗</text>}
        </g>
      ))}

      {/* Threshold line */}
      <g transform={`translate(40, 68)`}>
        <line x1={40 * 1.9 * 0.866} y1="0" x2={40 * 1.9 * 0.866} y2="195" stroke={RED} stroke-width="1" stroke-dasharray="3 3" opacity="0.5" transform={`skewY(-30)`} />
      </g>
      <text x="115" y="268" font-family="Departure Mono, monospace" font-size="6" fill={RED}>↑ threshold: 40</text>

      {/* Output */}
      <g transform="translate(280, 140)">
        <g transform={ISO}>
          <rect width="80" height="40" rx="4" fill={GLD} opacity="0.2" stroke={GLD} stroke-width="0.5" />
          <text x="8" y="18" font-family="Departure Mono, monospace" font-size="6" fill={GLD}>BEST</text>
          <text x="8" y="30" font-family="Departure Mono, monospace" font-size="7" fill={INK}>Wikidata 92</text>
        </g>
      </g>
    </svg>
  );
}

/** 3. LIBRARY — isometric flip card exploded view */
export function LibraryDiagram() {
  return (
    <svg viewBox="0 0 400 300" fill="none" xmlns="http://www.w3.org/2000/svg">
      <style>{`
        @keyframes flip-hint { 0%,80%,100% { transform: rotateY(0); } 90% { transform: rotateY(15deg); } }
        .flip-card { animation: flip-hint 4s ease-in-out infinite; transform-origin: center; }
      `}</style>

      {/* Front card — isometric */}
      <g transform="translate(30, 30)">
        <g transform={ISO}>
          <rect width="120" height="170" rx="6" fill={BRK} opacity="0.8" />
          <rect x="4" y="4" width="112" height="162" rx="4" fill={SAL} opacity="0.3" />
          {/* Poster lines */}
          <rect x="20" y="20" width="80" height="8" rx="1" fill={C} opacity="0.3" />
          <rect x="20" y="34" width="60" height="6" rx="1" fill={C} opacity="0.2" />
          <rect x="20" y="46" width="70" height="6" rx="1" fill={C} opacity="0.15" />
          <text x="30" y="100" font-family="Departure Mono, monospace" font-size="9" fill={C}>FRONT</text>
          <text x="20" y="115" font-family="Departure Mono, monospace" font-size="6" fill={C} opacity="0.7">poster + title</text>
          {/* Soundtrack badge */}
          <circle cx="100" cy="20" r="8" fill={GLD} opacity="0.8" />
          <text x="96" y="23" font-family="Departure Mono, monospace" font-size="6" fill={INK}>♪</text>
        </g>
      </g>

      {/* Flip arrow — animated */}
      <g transform="translate(165, 100)">
        <text font-family="Departure Mono, monospace" font-size="28" fill={GLD} opacity="0.8">⟲</text>
        <text x="-2" y="36" font-family="Departure Mono, monospace" font-size="6" fill={MUT}>tap</text>
      </g>

      {/* Back card — isometric right face */}
      <g transform="translate(200, 40)">
        <g transform={ISO_R}>
          <rect width="140" height="170" rx="6" fill={PAP} stroke={MID} stroke-width="0.5" />
          <text x="12" y="24" font-family="Departure Mono, monospace" font-size="6" fill={OX} letter-spacing="0.1em">DETAILS</text>
          <text x="12" y="42" font-family="Departure Mono, monospace" font-size="8" fill={INK}>Title (1967)</text>
          <text x="12" y="56" font-family="Departure Mono, monospace" font-size="6" fill={MUT}>Dir. Name · 101 min</text>
          <line x1="12" y1="64" x2="128" y2="64" stroke={MID} stroke-width="0.3" />
          <rect x="12" y="72" width="116" height="40" rx="2" fill={INK} opacity="0.03" />
          <text x="16" y="86" font-family="Departure Mono, monospace" font-size="5" fill={MID}>Overview text that</text>
          <text x="16" y="95" font-family="Departure Mono, monospace" font-size="5" fill={MID}>wraps to multiple</text>
          <text x="16" y="104" font-family="Departure Mono, monospace" font-size="5" fill={MID}>lines here...</text>
          {/* Buttons */}
          <rect x="12" y="124" width="52" height="16" rx="3" fill={RED} opacity="0.8" />
          <text x="16" y="135" font-family="Departure Mono, monospace" font-size="5" fill={C}>Criterion</text>
          <rect x="70" y="124" width="58" height="16" rx="3" fill={INK} opacity="0.08" />
          <text x="74" y="135" font-family="Departure Mono, monospace" font-size="5" fill={MID}>Letterboxd</text>
          <rect x="12" y="146" width="52" height="16" rx="3" fill={GLD} opacity="0.3" />
          <text x="16" y="157" font-family="Departure Mono, monospace" font-size="5" fill={INK}>♪ Soundtrack</text>
        </g>
      </g>

      {/* Filter chips — flat below */}
      <g transform="translate(30, 250)">
        <text font-family="Departure Mono, monospace" font-size="6" fill={MID} letter-spacing="0.1em">SEARCH + DECADE + COUNTRY FILTERS</text>
        {["All", "1960s", "1970s", "France", "Japan"].map((t, i) => (
          <>
            <rect x={i * 58} y={10} width={52} height={14} rx={7}
              fill={i === 2 ? GLD : "transparent"} stroke={i === 2 ? GLD : MID} stroke-width="0.5" opacity={i === 2 ? 0.7 : 0.3} />
            <text x={i * 58 + 8} y={20} font-family="Departure Mono, monospace" font-size="6" fill={i === 2 ? INK : MUT}>{t}</text>
          </>
        ))}
      </g>
    </svg>
  );
}

/** 4. HISTORY — isometric timeline with animated data flow */
export function HistoryDiagram() {
  return (
    <svg viewBox="0 0 400 280" fill="none" xmlns="http://www.w3.org/2000/svg">
      <style>{`
        @keyframes flow-down { 0% { cy: 48; opacity: 0; } 30% { opacity: 1; } 100% { cy: 80; opacity: 0; } }
        .pipe-flow { animation: flow-down 1.5s ease-in-out infinite; }
        .pipe-flow2 { animation: flow-down 1.5s ease-in-out 0.5s infinite; }
        .pipe-flow3 { animation: flow-down 1.5s ease-in-out 1s infinite; }
        @keyframes pulse-dot { 0%,100% { r: 4; opacity: 1; } 50% { r: 7; opacity: 0.5; } }
        .now-pulse { animation: pulse-dot 1.5s ease-in-out infinite; }
      `}</style>

      {/* Pipeline — isometric blocks */}
      <g transform="translate(20, 10)">
        <g transform={ISO}>
          <rect width="90" height="28" rx="4" fill={BRK} opacity="0.7" />
          <text x="10" y="18" font-family="Departure Mono, monospace" font-size="7" fill={C}>60s timer</text>
        </g>
      </g>

      {/* Flow dots between blocks */}
      <circle cx="125" cy="55" r="3" fill={GLD} class="pipe-flow" />
      <circle cx="125" cy="55" r="3" fill={GLD} class="pipe-flow2" />

      <g transform="translate(120, 10)">
        <g transform={ISO}>
          <rect width="90" height="28" rx="4" fill={GLD} opacity="0.3" stroke={GLD} stroke-width="0.5" />
          <text x="10" y="18" font-family="Departure Mono, monospace" font-size="7" fill={INK}>title ≠ last?</text>
        </g>
      </g>

      <circle cx="230" cy="55" r="3" fill={RED} class="pipe-flow3" />

      <g transform="translate(225, 10)">
        <g transform={ISO}>
          <rect width="90" height="28" rx="4" fill={RED} opacity="0.7" />
          <text x="10" y="18" font-family="Departure Mono, monospace" font-size="7" fill={C}>→ log entry</text>
        </g>
      </g>

      {/* Isometric timeline below */}
      <g transform="translate(50, 85)">
        <g transform={ISO}>
          {/* Day header */}
          <text font-family="Departure Mono, monospace" font-size="6" fill={GLD} letter-spacing="0.1em">● TODAY</text>
        </g>
      </g>

      {/* Timeline spine */}
      <line x1="70" y1="100" x2="70" y2="260" stroke={SAL} stroke-width="2" opacity="0.3" />

      {/* Entries */}
      {[
        { y: 110, time: "2:45 PM", title: "F for Fake", current: false },
        { y: 155, time: "1:20 PM", title: "Belle de Jour", current: true },
        { y: 200, time: "11:15 AM", title: "Killer of Sheep", current: false },
      ].map(e => (
        <>
          <circle cx="70" cy={e.y} r={e.current ? 5 : 3} fill={e.current ? RED : SAL} class={e.current ? "now-pulse" : ""} />
          <g transform={`translate(90, ${e.y - 16})`}>
            <g transform={ISO}>
              <rect width="180" height="30" rx="4" fill={e.current ? RED : INK} opacity={e.current ? 0.08 : 0.03} stroke={e.current ? RED : MID} stroke-width="0.3" />
              <text x="8" y="14" font-family="Departure Mono, monospace" font-size="5" fill={e.current ? RED : MUT}>{e.time}</text>
              <text x="60" y="14" font-family="Departure Mono, monospace" font-size="7" fill={INK}>{e.title}</text>
              {e.current && <text x="8" y="24" font-family="Departure Mono, monospace" font-size="5" fill={RED}>● NOW</text>}
            </g>
          </g>
        </>
      ))}
    </svg>
  );
}

/** 5. GEOGRAPHY — isometric globe cutaway */
export function GeographyDiagram() {
  return (
    <svg viewBox="0 0 400 320" fill="none" xmlns="http://www.w3.org/2000/svg">
      <style>{`
        @keyframes float { 0%,100% { transform: translateY(0); } 50% { transform: translateY(-3px); } }
        .float-card { animation: float 3s ease-in-out infinite; }
        .float-card2 { animation: float 3s ease-in-out 1s infinite; }
        .float-card3 { animation: float 3s ease-in-out 2s infinite; }
      `}</style>

      {/* Globe — isometric sphere approximation */}
      <ellipse cx="180" cy="170" rx="100" ry="90" fill={INK} opacity="0.05" />
      <ellipse cx="180" cy="170" rx="100" ry="90" fill="none" stroke={MID} stroke-width="0.8" />

      {/* Grid lines */}
      <ellipse cx="180" cy="170" rx="100" ry="35" fill="none" stroke={MID} stroke-width="0.3" opacity="0.3" />
      <ellipse cx="180" cy="170" rx="100" ry="65" fill="none" stroke={MID} stroke-width="0.3" opacity="0.2" />
      <ellipse cx="180" cy="170" rx="35" ry="90" fill="none" stroke={MID} stroke-width="0.3" opacity="0.3" />
      <line x1="80" y1="170" x2="280" y2="170" stroke={MID} stroke-width="0.3" opacity="0.2" />

      {/* Poster clusters on the globe */}
      {/* France */}
      {[0, 1, 2].map(i => (
        <rect x={182 + i * 7 - 3} y={138 + (i % 2) * 6} width="6" height="9" rx="1" fill={[RED, BRK, SAL][i]} opacity="0.8" />
      ))}

      {/* Japan */}
      {[0, 1].map(i => (
        <rect x={238 + i * 7} y={148 + i * 4} width="6" height="9" rx="1" fill={GLD} opacity={0.9 - i * 0.2} />
      ))}

      {/* USA */}
      {[0, 1, 2].map(i => (
        <rect x={110 + i * 7} y={152 + (i % 2) * 5} width="6" height="9" rx="1" fill={[OX, RED, BRK][i]} opacity="0.8" />
      ))}

      {/* Callout cards — floating outside the globe */}
      <g class="float-card">
        <line x1="190" y1="140" x2="310" y2="50" stroke={MID} stroke-width="0.5" />
        <circle cx="190" cy="140" r="2.5" fill={GLD} />
        <g transform="translate(295, 30)">
          <rect width="90" height="36" rx="3" fill={PAP} stroke={MID} stroke-width="0.3" />
          <rect x="4" y="4" width="18" height="26" rx="2" fill={BRK} opacity="0.5" />
          <text x="26" y="14" font-family="Departure Mono, monospace" font-size="6" fill={INK}>France</text>
          <text x="26" y="24" font-family="Departure Mono, monospace" font-size="8" fill={RED} font-weight="bold">12</text>
        </g>
      </g>

      <g class="float-card2">
        <line x1="245" y1="152" x2="330" y2="120" stroke={MID} stroke-width="0.5" />
        <circle cx="245" cy="152" r="2.5" fill={GLD} />
        <g transform="translate(315, 106)">
          <rect width="76" height="36" rx="3" fill={PAP} stroke={MID} stroke-width="0.3" />
          <rect x="4" y="4" width="18" height="26" rx="2" fill={GLD} opacity="0.5" />
          <text x="26" y="14" font-family="Departure Mono, monospace" font-size="6" fill={INK}>Japan</text>
          <text x="26" y="24" font-family="Departure Mono, monospace" font-size="8" fill={GLD} font-weight="bold">8</text>
        </g>
      </g>

      <g class="float-card3">
        <line x1="115" y1="155" x2="30" y2="90" stroke={MID} stroke-width="0.5" />
        <circle cx="115" cy="155" r="2.5" fill={GLD} />
        <g transform="translate(4, 72)">
          <rect width="76" height="36" rx="3" fill={PAP} stroke={MID} stroke-width="0.3" />
          <rect x="4" y="4" width="18" height="26" rx="2" fill={OX} opacity="0.5" />
          <text x="26" y="14" font-family="Departure Mono, monospace" font-size="6" fill={INK}>USA</text>
          <text x="26" y="24" font-family="Departure Mono, monospace" font-size="8" fill={OX} font-weight="bold">15</text>
        </g>
      </g>

      {/* Layer legend */}
      <text x="40" y="295" font-family="Departure Mono, monospace" font-size="5" fill={MUT} letter-spacing="0.08em">LAYERS: SceneKit sphere → billboarded posters → SwiftUI callout overlay</text>
    </svg>
  );
}

export const featureDiagrams: Record<string, () => any> = {
  amber: NowPlayingDiagram,
  flux: SoundtrackDiagram,
  foam: LibraryDiagram,
  clay: HistoryDiagram,
  pumpkin: GeographyDiagram,
};
