/** Handcrafted inline SVG cinema artifacts — ticket stubs, film cans, cue sheets */

export function TicketStub() {
  return (
    <svg viewBox="0 0 320 140" fill="none" xmlns="http://www.w3.org/2000/svg" class="artifact-svg">
      {/* Ticket body */}
      <rect x="2" y="2" width="316" height="136" rx="4" fill="#e6dbc8" stroke="#8b2017" stroke-width="1.5" />
      {/* Perforation line */}
      <line x1="240" y1="0" x2="240" y2="140" stroke="#8b2017" stroke-width="1" stroke-dasharray="4 4" />
      {/* Left section */}
      <text x="16" y="28" font-family="Departure Mono, monospace" font-size="8" fill="#6b5e52" letter-spacing="0.15em">CRITERION CHANNEL</text>
      <text x="16" y="58" font-family="Departure Mono, monospace" font-size="22" fill="#1a1613" font-weight="bold">ADMIT ONE</text>
      <text x="16" y="78" font-family="Departure Mono, monospace" font-size="9" fill="#8b2017">24/7 LIVE STREAM</text>
      <text x="16" y="100" font-family="Departure Mono, monospace" font-size="8" fill="#9c8e7e">HOUSE C · SCREEN 1 · ROW —</text>
      <text x="16" y="118" font-family="Departure Mono, monospace" font-size="8" fill="#9c8e7e">FORMAT: DIGITAL · NO REFUNDS</text>
      {/* Stub section */}
      <text x="254" y="28" font-family="Departure Mono, monospace" font-size="7" fill="#6b5e52" letter-spacing="0.1em">STUB</text>
      <text x="254" y="55" font-family="Departure Mono, monospace" font-size="16" fill="#c0392b" font-weight="bold">CN</text>
      <text x="254" y="75" font-family="Departure Mono, monospace" font-size="16" fill="#c0392b">247</text>
      <text x="254" y="100" font-family="Departure Mono, monospace" font-size="7" fill="#9c8e7e">RETAIN</text>
      <text x="254" y="112" font-family="Departure Mono, monospace" font-size="7" fill="#9c8e7e">THIS</text>
      <text x="254" y="124" font-family="Departure Mono, monospace" font-size="7" fill="#9c8e7e">PORTION</text>
      {/* Decorative circles (perforation holes) */}
      <circle cx="240" cy="0" r="6" fill="#f5f0e8" />
      <circle cx="240" cy="140" r="6" fill="#f5f0e8" />
    </svg>
  );
}

export function FilmCanLabel() {
  return (
    <svg viewBox="0 0 260 160" fill="none" xmlns="http://www.w3.org/2000/svg" class="artifact-svg">
      {/* Can label */}
      <rect x="2" y="2" width="256" height="156" rx="6" fill="#d45a3b" />
      <rect x="6" y="6" width="248" height="148" rx="4" fill="none" stroke="#e6dbc8" stroke-width="0.5" opacity="0.4" />
      {/* Text */}
      <text x="18" y="30" font-family="Departure Mono, monospace" font-size="7" fill="#e6dbc8" opacity="0.7" letter-spacing="0.15em">FILM STOCK</text>
      <text x="18" y="58" font-family="Departure Mono, monospace" font-size="20" fill="#e6dbc8" font-weight="bold">MY LIST</text>
      <text x="18" y="80" font-family="Departure Mono, monospace" font-size="10" fill="#e6dbc8" opacity="0.8">LOCAL CACHE · JSON</text>
      <line x1="18" y1="90" x2="242" y2="90" stroke="#e6dbc8" stroke-width="0.5" opacity="0.3" />
      <text x="18" y="108" font-family="Departure Mono, monospace" font-size="8" fill="#e6dbc8" opacity="0.6">COLLECTIONS  FLIP CARDS</text>
      <text x="18" y="122" font-family="Departure Mono, monospace" font-size="8" fill="#e6dbc8" opacity="0.6">SEARCH  FILTERS  POSTERS</text>
      <text x="18" y="146" font-family="Departure Mono, monospace" font-size="7" fill="#e6dbc8" opacity="0.4">HANDLE WITH CARE · DO NOT EXPOSE TO CLOUD</text>
    </svg>
  );
}

export function CueSheet() {
  return (
    <svg viewBox="0 0 240 200" fill="none" xmlns="http://www.w3.org/2000/svg" class="artifact-svg">
      {/* Paper */}
      <rect x="2" y="2" width="236" height="196" rx="2" fill="#e6dbc8" />
      {/* Red header stripe */}
      <rect x="2" y="2" width="236" height="28" rx="2" fill="#8b2017" />
      <text x="12" y="20" font-family="Departure Mono, monospace" font-size="9" fill="#e6dbc8" letter-spacing="0.15em">SOUNDTRACK CUE SHEET</text>
      {/* Ruled lines */}
      <line x1="12" y1="48" x2="228" y2="48" stroke="#9c8e7e" stroke-width="0.3" />
      <line x1="12" y1="66" x2="228" y2="66" stroke="#9c8e7e" stroke-width="0.3" />
      <line x1="12" y1="84" x2="228" y2="84" stroke="#9c8e7e" stroke-width="0.3" />
      <line x1="12" y1="102" x2="228" y2="102" stroke="#9c8e7e" stroke-width="0.3" />
      <line x1="12" y1="120" x2="228" y2="120" stroke="#9c8e7e" stroke-width="0.3" />
      {/* Content */}
      <text x="12" y="44" font-family="Departure Mono, monospace" font-size="7" fill="#6b5e52" letter-spacing="0.1em">SOURCE          STATUS    SCORE</text>
      <text x="12" y="62" font-family="Departure Mono, monospace" font-size="8" fill="#1a1613">Wikidata P406   ✓ Found   92</text>
      <text x="12" y="80" font-family="Departure Mono, monospace" font-size="8" fill="#1a1613">MusicBrainz     ✓ Found   87</text>
      <text x="12" y="98" font-family="Departure Mono, monospace" font-size="8" fill="#1a1613">Discogs         ✓ Found   74</text>
      <text x="12" y="116" font-family="Departure Mono, monospace" font-size="8" fill="#9c8e7e">iTunes          ✗ Below   38</text>
      <text x="12" y="134" font-family="Departure Mono, monospace" font-size="8" fill="#9c8e7e">Last.fm         ✗ Below   22</text>
      {/* Footer */}
      <line x1="12" y1="150" x2="228" y2="150" stroke="#8b2017" stroke-width="0.5" />
      <text x="12" y="166" font-family="Departure Mono, monospace" font-size="7" fill="#8b2017">THRESHOLD: 40 · BEST: WIKIDATA · 92%</text>
      <text x="12" y="182" font-family="Departure Mono, monospace" font-size="7" fill="#9c8e7e">6-DIMENSION WEIGHTED SCORING</text>
    </svg>
  );
}

export function ScreeningProgram() {
  return (
    <svg viewBox="0 0 200 280" fill="none" xmlns="http://www.w3.org/2000/svg" class="artifact-svg">
      {/* Folded program */}
      <rect x="2" y="2" width="196" height="276" rx="2" fill="#d8ccb8" />
      {/* Fold line */}
      <line x1="2" y1="140" x2="198" y2="140" stroke="#9c8e7e" stroke-width="0.5" stroke-dasharray="3 3" />
      {/* Top half — cover */}
      <rect x="14" y="14" width="172" height="112" rx="1" fill="#1a1613" />
      <text x="24" y="45" font-family="Departure Mono, monospace" font-size="6" fill="#d4a843" letter-spacing="0.2em">CRITERION NOW PRESENTS</text>
      <text x="24" y="75" font-family="Departure Mono, monospace" font-size="18" fill="#e6dbc8">NOW</text>
      <text x="24" y="95" font-family="Departure Mono, monospace" font-size="18" fill="#e6dbc8">PLAYING</text>
      <text x="24" y="115" font-family="Departure Mono, monospace" font-size="7" fill="#9c8e7e">LIVE · 24/7 · TMDB ENRICHED</text>
      {/* Bottom half — interior */}
      <text x="14" y="160" font-family="Departure Mono, monospace" font-size="7" fill="#6b5e52" letter-spacing="0.1em">PROGRAM NOTES</text>
      <text x="14" y="178" font-family="Departure Mono, monospace" font-size="8" fill="#2c2420">Progress bar ticks</text>
      <text x="14" y="192" font-family="Departure Mono, monospace" font-size="8" fill="#2c2420">every second. Film</text>
      <text x="14" y="206" font-family="Departure Mono, monospace" font-size="8" fill="#2c2420">change notifications</text>
      <text x="14" y="220" font-family="Departure Mono, monospace" font-size="8" fill="#2c2420">with poster image.</text>
      <text x="14" y="248" font-family="Departure Mono, monospace" font-size="7" fill="#8b2017">▸ MINI PLAYER · VIDEO + RADIO</text>
      <text x="14" y="264" font-family="Departure Mono, monospace" font-size="7" fill="#8b2017">▸ AUDIO VISUALIZER · SCROBBLING</text>
    </svg>
  );
}

export function DirectorSlate() {
  return (
    <svg viewBox="0 0 220 160" fill="none" xmlns="http://www.w3.org/2000/svg" class="artifact-svg">
      {/* Slate body */}
      <rect x="2" y="36" width="216" height="122" rx="3" fill="#2c2420" />
      {/* Clapstick top */}
      <path d="M2 36 L218 36 L218 12 L2 36Z" fill="#1a1613" />
      <path d="M2 36 L218 12 L218 2 L2 12Z" fill="#e6dbc8" />
      {/* Diagonal stripes on clapstick */}
      {[20, 55, 90, 125, 160, 195].map(x => (
        <line x1={x} y1="2" x2={x - 18} y2="36" stroke="#1a1613" stroke-width="8" />
      ))}
      {/* Text on slate */}
      <text x="14" y="56" font-family="Departure Mono, monospace" font-size="7" fill="#d4a843" letter-spacing="0.15em">CRITERION NOW</text>
      <text x="14" y="78" font-family="Departure Mono, monospace" font-size="8" fill="#e6dbc8" opacity="0.7">PROD: Menu Bar</text>
      <text x="14" y="94" font-family="Departure Mono, monospace" font-size="8" fill="#e6dbc8" opacity="0.7">DIR:  SwiftUI</text>
      <text x="14" y="110" font-family="Departure Mono, monospace" font-size="8" fill="#e6dbc8" opacity="0.7">CAM:  SceneKit</text>
      <text x="14" y="126" font-family="Departure Mono, monospace" font-size="8" fill="#e6dbc8" opacity="0.7">TAKE: 24/7</text>
      <text x="140" y="148" font-family="Departure Mono, monospace" font-size="7" fill="#d45a3b">● REC</text>
    </svg>
  );
}

export function ProjectorReel() {
  return (
    <svg viewBox="0 0 180 180" fill="none" xmlns="http://www.w3.org/2000/svg" class="artifact-svg">
      {/* Outer ring */}
      <circle cx="90" cy="90" r="86" fill="none" stroke="#8b2017" stroke-width="2" />
      <circle cx="90" cy="90" r="80" fill="#2c2420" />
      {/* Spokes */}
      {[0, 60, 120, 180, 240, 300].map(angle => {
        const rad = (angle * Math.PI) / 180;
        return <line x1="90" y1="90" x2={90 + 72 * Math.cos(rad)} y2={90 + 72 * Math.sin(rad)} stroke="#1a1613" stroke-width="6" />;
      })}
      {/* Windows between spokes */}
      {[30, 90, 150, 210, 270, 330].map(angle => {
        const rad = (angle * Math.PI) / 180;
        return <circle cx={90 + 50 * Math.cos(rad)} cy={90 + 50 * Math.sin(rad)} r="16" fill="#1a1613" stroke="#8b2017" stroke-width="0.5" />;
      })}
      {/* Hub */}
      <circle cx="90" cy="90" r="18" fill="#d45a3b" />
      <circle cx="90" cy="90" r="12" fill="#2c2420" />
      <circle cx="90" cy="90" r="4" fill="#d4a843" />
      {/* Label */}
      <text x="76" y="94" font-family="Departure Mono, monospace" font-size="5" fill="#d4a843">REEL</text>
    </svg>
  );
}

export function SeasonPass() {
  return (
    <svg viewBox="0 0 180 260" fill="none" xmlns="http://www.w3.org/2000/svg" class="artifact-svg">
      {/* Badge body */}
      <rect x="2" y="2" width="176" height="256" rx="8" fill="#d45a3b" />
      <rect x="6" y="6" width="168" height="248" rx="6" fill="none" stroke="#e6dbc8" stroke-width="0.5" opacity="0.3" />
      {/* Lanyard hole */}
      <circle cx="90" cy="20" r="8" fill="#2c2420" />
      <circle cx="90" cy="20" r="5" fill="#d45a3b" />
      {/* Photo area */}
      <rect x="40" y="40" width="100" height="100" rx="4" fill="#e6dbc8" opacity="0.15" />
      <text x="68" y="95" font-family="Departure Mono, monospace" font-size="20" fill="#e6dbc8" opacity="0.4">▶</text>
      {/* Text */}
      <text x="16" y="162" font-family="Departure Mono, monospace" font-size="7" fill="#e6dbc8" opacity="0.6" letter-spacing="0.15em">SEASON PASS</text>
      <text x="16" y="182" font-family="Departure Mono, monospace" font-size="14" fill="#e6dbc8" font-weight="bold">ALL</text>
      <text x="16" y="200" font-family="Departure Mono, monospace" font-size="14" fill="#e6dbc8" font-weight="bold">ACCESS</text>
      <text x="16" y="220" font-family="Departure Mono, monospace" font-size="8" fill="#e6dbc8" opacity="0.5">CRITERION CHANNEL</text>
      <text x="16" y="240" font-family="Departure Mono, monospace" font-size="7" fill="#d4a843">VALID: INDEFINITE</text>
    </svg>
  );
}

export function TimelineStrip() {
  return (
    <svg viewBox="0 0 300 80" fill="none" xmlns="http://www.w3.org/2000/svg" class="artifact-svg">
      <rect x="0" y="0" width="300" height="80" fill="#1a1613" />
      {[20, 50, 80, 110, 140, 170, 200, 230, 260].map(x => (
        <>
          <rect x={x} y="4" width="10" height="8" rx="2" fill="#2c2420" />
          <rect x={x} y="68" width="10" height="8" rx="2" fill="#2c2420" />
        </>
      ))}
      {[15, 65, 115, 165, 215].map((x, i) => (
        <rect x={x} y="16" width="40" height="48" rx="1" fill={["#c0392b", "#d45a3b", "#d4a843", "#e8a090", "#8b2017"][i]} opacity="0.8" />
      ))}
      <circle cx="270" cy="40" r="4" fill="none" stroke="#d4a843" stroke-width="1" />
      <text x="8" y="44" font-family="Departure Mono, monospace" font-size="6" fill="#6b5e52">HISTORY</text>
    </svg>
  );
}

export function PopcornBox() {
  return (
    <svg viewBox="0 0 160 200" fill="none" xmlns="http://www.w3.org/2000/svg" class="artifact-svg">
      {/* Box body — tapered */}
      <path d="M30 70 L15 195 Q15 200 20 200 L140 200 Q145 200 145 195 L130 70Z" fill="#c0392b" />
      {/* Red/white stripes */}
      {[38, 58, 78, 98, 118].map(x => (
        <path d={`M${x} 70 L${x - 8} 200`} stroke="#e6dbc8" stroke-width="10" opacity="0.25" />
      ))}
      {/* Box rim */}
      <ellipse cx="80" cy="70" rx="52" ry="8" fill="#8b2017" />
      <ellipse cx="80" cy="70" rx="50" ry="7" fill="#c0392b" />
      {/* Popcorn kernels — irregular circles piled above */}
      {[
        [56, 58, 11], [80, 52, 13], [104, 56, 10], [68, 42, 12], [92, 44, 11],
        [58, 34, 9], [80, 30, 11], [100, 36, 10], [72, 24, 10], [88, 22, 9],
        [66, 16, 8], [80, 12, 9], [94, 16, 8], [76, 6, 7]
      ].map(([cx, cy, r]) => (
        <circle cx={cx} cy={cy} r={r} fill="#e6dbc8" stroke="#d4a843" stroke-width="0.5" />
      ))}
      {/* Shadow on kernels */}
      {[
        [58, 36, 6], [82, 26, 7], [96, 32, 5], [74, 18, 5]
      ].map(([cx, cy, r]) => (
        <circle cx={cx} cy={cy} r={r} fill="#d4a843" opacity="0.2" />
      ))}
      {/* Label */}
      <text x="48" y="140" font-family="Departure Mono, monospace" font-size="9" fill="#e6dbc8" font-weight="bold" letter-spacing="0.1em">POP</text>
      <text x="42" y="158" font-family="Departure Mono, monospace" font-size="9" fill="#e6dbc8" font-weight="bold" letter-spacing="0.1em">CORN</text>
      <text x="42" y="180" font-family="Departure Mono, monospace" font-size="5" fill="#e6dbc8" opacity="0.5">EXTRA BUTTER</text>
    </svg>
  );
}

export function TornTicket() {
  return (
    <svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg" class="artifact-svg">
      {/* Torn ticket — irregular right edge */}
      <path d="M2 2 L2 118 L198 118 L196 112 L200 104 L195 96 L199 88 L194 80 L198 72 L193 64 L197 56 L194 48 L198 40 L195 32 L199 24 L196 16 L200 8 L197 2Z"
        fill="#e6dbc8" stroke="#8b2017" stroke-width="1" />
      {/* Stain / aging effect */}
      <circle cx="160" cy="90" r="20" fill="#d4a843" opacity="0.08" />
      <circle cx="30" cy="30" r="15" fill="#8b2017" opacity="0.04" />
      {/* Content */}
      <text x="12" y="20" font-family="Departure Mono, monospace" font-size="6" fill="#8b2017" letter-spacing="0.15em">THE CRITERION CHANNEL</text>
      <text x="12" y="46" font-family="Departure Mono, monospace" font-size="16" fill="#1a1613" font-weight="bold">USED</text>
      <text x="12" y="66" font-family="Departure Mono, monospace" font-size="9" fill="#6b5e52">SCREENING #2847</text>
      <text x="12" y="84" font-family="Departure Mono, monospace" font-size="8" fill="#9c8e7e">DATE: TONIGHT</text>
      <text x="12" y="100" font-family="Departure Mono, monospace" font-size="8" fill="#9c8e7e">SEAT: ANYWHERE · HOME</text>
      {/* Stamped "ENJOYED" diagonally */}
      <text x="90" y="75" font-family="Departure Mono, monospace" font-size="14" fill="#c0392b" opacity="0.35" transform="rotate(-18 90 75)" font-weight="bold">ENJOYED</text>
    </svg>
  );
}

export function FilmRating() {
  return (
    <svg viewBox="0 0 120 120" fill="none" xmlns="http://www.w3.org/2000/svg" class="artifact-svg">
      {/* Circle badge */}
      <circle cx="60" cy="60" r="56" fill="#1a1613" stroke="#d4a843" stroke-width="2" />
      <circle cx="60" cy="60" r="48" fill="none" stroke="#d4a843" stroke-width="0.5" />
      {/* Inner content */}
      <text x="60" y="38" font-family="Departure Mono, monospace" font-size="6" fill="#d4a843" text-anchor="middle" letter-spacing="0.2em">RATED</text>
      <text x="60" y="72" font-family="Departure Mono, monospace" font-size="32" fill="#e6dbc8" text-anchor="middle" font-weight="bold">CN</text>
      <text x="60" y="88" font-family="Departure Mono, monospace" font-size="5" fill="#9c8e7e" text-anchor="middle" letter-spacing="0.15em">CRITERION NOW</text>
      <text x="60" y="100" font-family="Departure Mono, monospace" font-size="5" fill="#d45a3b" text-anchor="middle">FOR CINEPHILES ONLY</text>
    </svg>
  );
}

export function Filmstrip3D() {
  return (
    <svg viewBox="0 0 100 300" fill="none" xmlns="http://www.w3.org/2000/svg" class="artifact-svg">
      {/* Vertical film strip with slight curve */}
      <rect x="8" y="0" width="84" height="300" fill="#1a1613" rx="2" />
      {/* Sprocket holes — left and right */}
      {[12, 42, 72, 102, 132, 162, 192, 222, 252, 282].map(y => (
        <>
          <rect x="12" y={y} width="8" height="6" rx="1.5" fill="#2c2420" />
          <rect x="80" y={y} width="8" height="6" rx="1.5" fill="#2c2420" />
        </>
      ))}
      {/* Frames with colors */}
      {[
        [8, "#c0392b"], [58, "#d45a3b"], [108, "#d4a843"],
        [158, "#e8a090"], [208, "#8b2017"], [258, "#d45a3b"]
      ].map(([y, color]) => (
        <rect x="24" y={y as number} width="52" height="38" rx="1" fill={color as string} opacity="0.8" />
      ))}
      {/* Frame numbers */}
      <text x="28" y="20" font-family="Departure Mono, monospace" font-size="5" fill="#6b5e52">001</text>
      <text x="28" y="70" font-family="Departure Mono, monospace" font-size="5" fill="#6b5e52">002</text>
      <text x="28" y="120" font-family="Departure Mono, monospace" font-size="5" fill="#6b5e52">003</text>
    </svg>
  );
}

export function VinylRecord() {
  return (
    <svg viewBox="0 0 180 180" fill="none" xmlns="http://www.w3.org/2000/svg" class="artifact-svg">
      {/* Outer edge */}
      <circle cx="90" cy="90" r="88" fill="#1a1613" />
      {/* Grooves */}
      {[78, 68, 58, 48, 38].map(r => (
        <circle cx="90" cy="90" r={r} fill="none" stroke="#2c2420" stroke-width="0.5" />
      ))}
      {/* Light reflection */}
      <ellipse cx="70" cy="60" rx="40" ry="15" fill="white" opacity="0.03" transform="rotate(-30 70 60)" />
      {/* Label */}
      <circle cx="90" cy="90" r="28" fill="#c0392b" />
      <circle cx="90" cy="90" r="26" fill="none" stroke="#8b2017" stroke-width="0.5" />
      <text x="90" y="82" font-family="Departure Mono, monospace" font-size="5" fill="#e6dbc8" text-anchor="middle" letter-spacing="0.15em">SOUNDTRACK</text>
      <text x="90" y="94" font-family="Departure Mono, monospace" font-size="8" fill="#e6dbc8" text-anchor="middle" font-weight="bold">OST</text>
      <text x="90" y="106" font-family="Departure Mono, monospace" font-size="4" fill="#e6dbc8" text-anchor="middle" opacity="0.6">5-SOURCE VERIFIED</text>
      {/* Center hole */}
      <circle cx="90" cy="90" r="4" fill="#1a1613" />
    </svg>
  );
}

export function Megaphone() {
  return (
    <svg viewBox="0 0 220 160" fill="none" xmlns="http://www.w3.org/2000/svg" class="artifact-svg">
      {/* Cone body */}
      <path d="M40 55 L180 20 L180 130 L40 95Z" fill="#d45a3b" />
      <path d="M40 55 L180 20 L180 130 L40 95Z" fill="none" stroke="#8b2017" stroke-width="1.5" />
      {/* Ribbed lines on cone */}
      <line x1="70" y1="50" x2="70" y2="100" stroke="#8b2017" stroke-width="0.5" opacity="0.4" />
      <line x1="100" y1="43" x2="100" y2="107" stroke="#8b2017" stroke-width="0.5" opacity="0.4" />
      <line x1="130" y1="36" x2="130" y2="114" stroke="#8b2017" stroke-width="0.5" opacity="0.4" />
      <line x1="160" y1="27" x2="160" y2="123" stroke="#8b2017" stroke-width="0.5" opacity="0.4" />
      {/* Bell mouth */}
      <ellipse cx="180" cy="75" rx="12" ry="56" fill="#c0392b" stroke="#8b2017" stroke-width="1" />
      {/* Handle end */}
      <rect x="16" y="60" width="28" height="30" rx="4" fill="#2c2420" />
      <rect x="20" y="64" width="20" height="22" rx="2" fill="#1a1613" />
      {/* Handle grip */}
      <rect x="22" y="96" width="16" height="36" rx="3" fill="#2c2420" />
      <rect x="24" y="100" width="12" height="28" rx="2" fill="#1a1613" />
      {/* Trigger button */}
      <circle cx="30" cy="108" r="3" fill="#d4a843" />
      {/* Sound waves */}
      <path d="M196 55 Q210 75 196 95" fill="none" stroke="#d4a843" stroke-width="1.5" opacity="0.5" />
      <path d="M204 42 Q222 75 204 108" fill="none" stroke="#d4a843" stroke-width="1" opacity="0.3" />
      {/* Label */}
      <text x="80" y="80" font-family="Departure Mono, monospace" font-size="7" fill="#e6dbc8" opacity="0.6" letter-spacing="0.1em">ACTION!</text>
    </svg>
  );
}

export function DirectorsChair() {
  return (
    <svg viewBox="0 0 160 200" fill="none" xmlns="http://www.w3.org/2000/svg" class="artifact-svg">
      {/* Back legs (X frame) */}
      <line x1="30" y1="40" x2="130" y2="195" stroke="#2c2420" stroke-width="5" stroke-linecap="round" />
      <line x1="130" y1="40" x2="30" y2="195" stroke="#2c2420" stroke-width="5" stroke-linecap="round" />
      {/* Front legs */}
      <line x1="40" y1="80" x2="40" y2="195" stroke="#2c2420" stroke-width="5" stroke-linecap="round" />
      <line x1="120" y1="80" x2="120" y2="195" stroke="#2c2420" stroke-width="5" stroke-linecap="round" />
      {/* Seat canvas */}
      <path d="M32 100 Q80 115 128 100 L128 85 Q80 100 32 85Z" fill="#c0392b" stroke="#8b2017" stroke-width="0.5" />
      {/* Back rest canvas */}
      <rect x="28" y="30" width="104" height="50" rx="2" fill="#c0392b" stroke="#8b2017" stroke-width="0.5" />
      {/* Text on back rest */}
      <text x="80" y="52" font-family="Departure Mono, monospace" font-size="7" fill="#e6dbc8" text-anchor="middle" letter-spacing="0.15em">DIRECTOR</text>
      <text x="80" y="68" font-family="Departure Mono, monospace" font-size="5" fill="#d4a843" text-anchor="middle" letter-spacing="0.1em">CRITERION NOW</text>
      {/* Arm rests */}
      <rect x="25" y="78" width="110" height="5" rx="2" fill="#2c2420" />
      {/* Cross bar */}
      <line x1="40" y1="140" x2="120" y2="140" stroke="#2c2420" stroke-width="3" stroke-linecap="round" />
      {/* Foot caps */}
      <rect x="34" y="192" width="12" height="4" rx="1" fill="#1a1613" />
      <rect x="114" y="192" width="12" height="4" rx="1" fill="#1a1613" />
    </svg>
  );
}

export function FilmAward() {
  return (
    <svg viewBox="0 0 120 200" fill="none" xmlns="http://www.w3.org/2000/svg" class="artifact-svg">
      {/* Base */}
      <rect x="35" y="170" width="50" height="12" rx="2" fill="#2c2420" />
      <rect x="40" y="164" width="40" height="10" rx="2" fill="#1a1613" />
      {/* Stem */}
      <rect x="55" y="100" width="10" height="68" fill="#d4a843" />
      <rect x="50" y="96" width="20" height="8" rx="2" fill="#d4a843" />
      {/* Star */}
      <path d="M60 8 L68 36 L98 36 L74 54 L82 82 L60 66 L38 82 L46 54 L22 36 L52 36Z" fill="#d4a843" stroke="#c0392b" stroke-width="1" />
      {/* Inner star detail */}
      <path d="M60 22 L65 38 L82 38 L69 48 L73 64 L60 55 L47 64 L51 48 L38 38 L55 38Z" fill="none" stroke="#e6dbc8" stroke-width="0.5" opacity="0.4" />
      {/* Label on base */}
      <text x="60" y="182" font-family="Departure Mono, monospace" font-size="5" fill="#d4a843" text-anchor="middle" letter-spacing="0.1em">BEST APP</text>
    </svg>
  );
}

export function OscarStatuette() {
  return (
    <svg viewBox="0 0 130 260" fill="none" xmlns="http://www.w3.org/2000/svg" class="artifact-svg">
      <rect x="28" y="226" width="74" height="16" rx="3" fill="#2c2420" />
      <rect x="36" y="216" width="58" height="12" rx="3" fill="#1a1613" />
      <ellipse cx="65" cy="210" rx="26" ry="10" fill="#d4a843" />
      <path d="M55 58C55 52.4772 59.4772 48 65 48C70.5228 48 75 52.4772 75 58V74C75 79.5228 70.5228 84 65 84C59.4772 84 55 79.5228 55 74V58Z" fill="#d4a843" />
      <circle cx="65" cy="34" r="14" fill="#d4a843" />
      <path d="M46 92L57 72H73L84 92L76 120L84 196H70L65 140L60 196H46L54 120L46 92Z" fill="#d4a843" />
      <path d="M52 98L33 132" stroke="#d4a843" stroke-width="8" stroke-linecap="round" />
      <path d="M78 98L97 132" stroke="#d4a843" stroke-width="8" stroke-linecap="round" />
      <path d="M58 196L50 214" stroke="#d4a843" stroke-width="8" stroke-linecap="round" />
      <path d="M72 196L80 214" stroke="#d4a843" stroke-width="8" stroke-linecap="round" />
      <text x="65" y="237" font-family="Departure Mono, monospace" font-size="5" fill="#d4a843" text-anchor="middle" letter-spacing="0.1em">BEST PICTURE</text>
    </svg>
  );
}

export function TheatreFacade() {
  return (
    <svg viewBox="0 0 280 220" fill="none" xmlns="http://www.w3.org/2000/svg" class="artifact-svg">
      <rect x="22" y="88" width="236" height="118" rx="4" fill="#e6dbc8" stroke="#8b2017" stroke-width="1.5" />
      <rect x="42" y="116" width="38" height="72" fill="#d8ccb8" stroke="#9c8e7e" stroke-width="0.6" />
      <rect x="200" y="116" width="38" height="72" fill="#d8ccb8" stroke="#9c8e7e" stroke-width="0.6" />
      <rect x="98" y="126" width="84" height="62" fill="#1a1613" />
      <path d="M140 126V188" stroke="#8b2017" stroke-width="1" stroke-dasharray="3 3" />
      <path d="M98 126C116 140 124 148 140 170C156 148 164 140 182 126V188H98V126Z" fill="#8b2017" opacity="0.78" />
      <rect x="32" y="52" width="216" height="44" rx="4" fill="#1a1613" stroke="#8b2017" stroke-width="1.5" />
      <rect x="42" y="62" width="196" height="24" rx="2" fill="#2c2420" />
      <text x="140" y="71" font-family="Departure Mono, monospace" font-size="7" fill="#d4a843" text-anchor="middle" letter-spacing="0.2em">REVIVAL HOUSE</text>
      <text x="140" y="82" font-family="Departure Mono, monospace" font-size="8" fill="#e6dbc8" text-anchor="middle">TONIGHT ONLY</text>
      {[
        42, 58, 74, 90, 106, 122, 138, 154, 170, 186, 202, 218, 234
      ].map((x) => (
        <circle cx={x} cy="100" r="3" fill="#d4a843" />
      ))}
      <path d="M60 52L74 16H206L220 52H60Z" fill="#c0392b" stroke="#8b2017" stroke-width="1.5" />
      <text x="140" y="35" font-family="Departure Mono, monospace" font-size="8" fill="#f5f0e8" text-anchor="middle" letter-spacing="0.18em">CINEMA</text>
      <text x="140" y="213" font-family="Departure Mono, monospace" font-size="6" fill="#6b5e52" text-anchor="middle" letter-spacing="0.12em">SCREEN 1 · BOX OFFICE OPEN</text>
    </svg>
  );
}

export function BoxOfficeBooth() {
  return (
    <svg viewBox="0 0 220 240" fill="none" xmlns="http://www.w3.org/2000/svg" class="artifact-svg">
      <rect x="26" y="52" width="168" height="168" rx="6" fill="#e6dbc8" stroke="#8b2017" stroke-width="1.4" />
      <rect x="42" y="90" width="136" height="80" rx="4" fill="#1a1613" />
      <rect x="54" y="102" width="112" height="56" rx="3" fill="#201b18" stroke="#d4a843" stroke-width="0.7" />
      <rect x="96" y="170" width="28" height="8" rx="2" fill="#2c2420" />
      <rect x="82" y="182" width="56" height="12" rx="3" fill="#d8ccb8" stroke="#9c8e7e" stroke-width="0.6" />
      <path d="M26 52L46 18H174L194 52H26Z" fill="#c0392b" stroke="#8b2017" stroke-width="1.4" />
      {[
        46, 60, 74, 88, 102, 116, 130, 144, 158, 172
      ].map((x) => (
        <line x1={x} y1="18" x2={x - 10} y2="52" stroke="#e6dbc8" stroke-width="8" opacity="0.25" />
      ))}
      <text x="110" y="38" font-family="Departure Mono, monospace" font-size="9" fill="#f5f0e8" text-anchor="middle" letter-spacing="0.18em">BOX OFFICE</text>
      <text x="110" y="118" font-family="Departure Mono, monospace" font-size="7" fill="#d4a843" text-anchor="middle" letter-spacing="0.12em">TICKETS · PASSES · OPEN</text>
      <text x="110" y="142" font-family="Departure Mono, monospace" font-size="14" fill="#e6dbc8" text-anchor="middle" font-weight="bold">NEXT SHOW</text>
      <text x="110" y="156" font-family="Departure Mono, monospace" font-size="8" fill="#9c8e7e" text-anchor="middle">24/7 PROGRAM</text>
      <circle cx="60" cy="206" r="6" fill="#d4a843" opacity="0.4" />
      <circle cx="160" cy="206" r="6" fill="#d4a843" opacity="0.4" />
    </svg>
  );
}

export function JanusCard() {
  return (
    <svg viewBox="0 0 180 220" fill="none" xmlns="http://www.w3.org/2000/svg" class="artifact-svg">
      <rect x="2" y="2" width="176" height="216" rx="8" fill="#1a1613" stroke="#d4a843" stroke-width="1.2" />
      <rect x="14" y="14" width="152" height="192" rx="4" fill="none" stroke="#8b2017" stroke-width="0.8" opacity="0.7" />
      <circle cx="90" cy="92" r="42" fill="none" stroke="#d4a843" stroke-width="1.2" />
      <path d="M90 52C78 58 72 70 72 90C72 110 78 122 90 132C102 122 108 110 108 90C108 70 102 58 90 52Z" fill="#c0392b" opacity="0.92" />
      <path d="M90 52C83 60 80 72 80 90C80 108 83 120 90 132" stroke="#f5f0e8" stroke-width="0.8" opacity="0.55" />
      <path d="M90 52C97 60 100 72 100 90C100 108 97 120 90 132" stroke="#f5f0e8" stroke-width="0.8" opacity="0.55" />
      <circle cx="76" cy="86" r="2.4" fill="#f5f0e8" />
      <circle cx="104" cy="86" r="2.4" fill="#f5f0e8" />
      <text x="90" y="34" font-family="Departure Mono, monospace" font-size="8" fill="#d4a843" text-anchor="middle" letter-spacing="0.2em">JANUS FILMS</text>
      <text x="90" y="156" font-family="Departure Mono, monospace" font-size="7" fill="#e6dbc8" text-anchor="middle" letter-spacing="0.15em">WORLD CINEMA</text>
      <text x="90" y="170" font-family="Departure Mono, monospace" font-size="7" fill="#9c8e7e" text-anchor="middle">DISTRIBUTOR CARD</text>
      <text x="90" y="192" font-family="Departure Mono, monospace" font-size="5" fill="#6b5e52" text-anchor="middle" letter-spacing="0.1em">DOUBLE-FACE REPERTORY SEAL</text>
    </svg>
  );
}

export function FestivalLaurels() {
  return (
    <svg viewBox="0 0 240 170" fill="none" xmlns="http://www.w3.org/2000/svg" class="artifact-svg">
      {[0, 1, 2, 3, 4, 5].map((i) => (
        <ellipse cx={52 - i * 4} cy={42 + i * 16} rx="10" ry="5" transform={`rotate(${-42 + i * 7} ${52 - i * 4} ${42 + i * 16})`} fill="#d4a843" />
      ))}
      {[0, 1, 2, 3, 4, 5].map((i) => (
        <ellipse cx={188 + i * 4} cy={42 + i * 16} rx="10" ry="5" transform={`rotate(${42 - i * 7} ${188 + i * 4} ${42 + i * 16})`} fill="#d4a843" />
      ))}
      <path d="M72 24C58 42 52 70 52 118" stroke="#d4a843" stroke-width="2" />
      <path d="M168 24C182 42 188 70 188 118" stroke="#d4a843" stroke-width="2" />
      <text x="120" y="58" font-family="Departure Mono, monospace" font-size="8" fill="#8b2017" text-anchor="middle" letter-spacing="0.22em">OFFICIAL</text>
      <text x="120" y="84" font-family="Departure Mono, monospace" font-size="16" fill="#1a1613" text-anchor="middle" font-weight="bold">SELECTION</text>
      <text x="120" y="104" font-family="Departure Mono, monospace" font-size="8" fill="#6b5e52" text-anchor="middle" letter-spacing="0.18em">REPERTORY CINEMA</text>
      <text x="120" y="132" font-family="Departure Mono, monospace" font-size="7" fill="#9c8e7e" text-anchor="middle">FROM THE CRITERION NOW FESTIVAL DESK</text>
    </svg>
  );
}

export function UsherFlashlight() {
  return (
    <svg viewBox="0 0 220 140" fill="none" xmlns="http://www.w3.org/2000/svg" class="artifact-svg">
      <path d="M130 54L214 18V122L130 86Z" fill="#d4a843" opacity="0.18" />
      <path d="M42 74L96 52L132 70L78 92Z" fill="#2c2420" stroke="#1a1613" stroke-width="1.2" />
      <path d="M30 62L58 50L84 80L56 92Z" fill="#c0392b" stroke="#8b2017" stroke-width="1.2" />
      <rect x="10" y="62" width="24" height="18" rx="4" fill="#1a1613" />
      <circle cx="138" cy="70" r="10" fill="#e6dbc8" opacity="0.6" />
      <circle cx="138" cy="70" r="5" fill="#f5f0e8" />
      <text x="74" y="116" font-family="Departure Mono, monospace" font-size="8" fill="#6b5e52" letter-spacing="0.12em">USHER LIGHT</text>
    </svg>
  );
}

export function TicketStrip() {
  return (
    <svg viewBox="0 0 300 110" fill="none" xmlns="http://www.w3.org/2000/svg" class="artifact-svg">
      <rect x="2" y="10" width="296" height="90" rx="4" fill="#e6dbc8" stroke="#8b2017" stroke-width="1.4" />
      {[102, 202].map((x) => (
        <line x1={x} y1="10" x2={x} y2="100" stroke="#8b2017" stroke-width="1" stroke-dasharray="4 4" />
      ))}
      {[102, 202].map((x) => (
        <>
          <circle cx={x} cy="10" r="6" fill="#f5f0e8" />
          <circle cx={x} cy="100" r="6" fill="#f5f0e8" />
        </>
      ))}
      <text x="22" y="34" font-family="Departure Mono, monospace" font-size="7" fill="#6b5e52" letter-spacing="0.14em">ADMISSION STRIP</text>
      <text x="22" y="56" font-family="Departure Mono, monospace" font-size="16" fill="#1a1613" font-weight="bold">MATINEE</text>
      <text x="22" y="76" font-family="Departure Mono, monospace" font-size="8" fill="#9c8e7e">HOUSE A · REVIVAL</text>
      <text x="122" y="34" font-family="Departure Mono, monospace" font-size="7" fill="#6b5e52" letter-spacing="0.14em">STUB</text>
      <text x="122" y="58" font-family="Departure Mono, monospace" font-size="18" fill="#c0392b" font-weight="bold">CN</text>
      <text x="122" y="76" font-family="Departure Mono, monospace" font-size="8" fill="#9c8e7e">KEEP THIS</text>
      <text x="222" y="34" font-family="Departure Mono, monospace" font-size="7" fill="#6b5e52" letter-spacing="0.14em">LATE SHOW</text>
      <text x="222" y="56" font-family="Departure Mono, monospace" font-size="16" fill="#1a1613" font-weight="bold">24/7</text>
      <text x="222" y="76" font-family="Departure Mono, monospace" font-size="8" fill="#9c8e7e">CONTINUOUS</text>
    </svg>
  );
}

export function ProjectionLens() {
  return (
    <svg viewBox="0 0 180 180" fill="none" xmlns="http://www.w3.org/2000/svg" class="artifact-svg">
      <circle cx="90" cy="90" r="56" fill="#2c2420" stroke="#1a1613" stroke-width="2" />
      <circle cx="90" cy="90" r="42" fill="#1a1613" stroke="#6b5e52" stroke-width="1" />
      <circle cx="90" cy="90" r="28" fill="#23313a" stroke="#d4a843" stroke-width="1.2" />
      <circle cx="90" cy="90" r="14" fill="#5d8798" opacity="0.7" />
      <ellipse cx="78" cy="76" rx="22" ry="10" fill="white" opacity="0.08" transform="rotate(-30 78 76)" />
      <rect x="46" y="70" width="18" height="40" rx="4" fill="#1a1613" />
      <rect x="116" y="70" width="18" height="40" rx="4" fill="#1a1613" />
      <text x="90" y="154" font-family="Departure Mono, monospace" font-size="7" fill="#6b5e52" text-anchor="middle" letter-spacing="0.14em">PROJECTION LENS</text>
    </svg>
  );
}

export function PressKitFolder() {
  return (
    <svg viewBox="0 0 250 180" fill="none" xmlns="http://www.w3.org/2000/svg" class="artifact-svg">
      <path d="M8 42H102L118 26H242V168H8V42Z" fill="#d8ccb8" stroke="#8b2017" stroke-width="1.4" />
      <rect x="22" y="58" width="206" height="96" rx="4" fill="#efe6d8" stroke="#9c8e7e" stroke-width="0.6" />
      <rect x="22" y="58" width="70" height="20" fill="#c0392b" />
      <text x="57" y="71" font-family="Departure Mono, monospace" font-size="8" fill="#f5f0e8" text-anchor="middle" letter-spacing="0.16em">PRESS KIT</text>
      <text x="34" y="96" font-family="Departure Mono, monospace" font-size="8" fill="#1a1613">Synopsis</text>
      <line x1="92" y1="93" x2="204" y2="93" stroke="#9c8e7e" stroke-width="0.6" />
      <text x="34" y="116" font-family="Departure Mono, monospace" font-size="8" fill="#1a1613">Cast</text>
      <line x1="62" y1="113" x2="204" y2="113" stroke="#9c8e7e" stroke-width="0.6" />
      <text x="34" y="136" font-family="Departure Mono, monospace" font-size="8" fill="#1a1613">Quotes</text>
      <line x1="76" y1="133" x2="204" y2="133" stroke="#9c8e7e" stroke-width="0.6" />
      <text x="126" y="28" font-family="Departure Mono, monospace" font-size="7" fill="#6b5e52" letter-spacing="0.14em">REVIEWER MATERIAL</text>
    </svg>
  );
}

export function ProgramEnvelope() {
  return (
    <svg viewBox="0 0 250 170" fill="none" xmlns="http://www.w3.org/2000/svg" class="artifact-svg">
      <rect x="8" y="26" width="234" height="136" rx="6" fill="#e6dbc8" stroke="#8b2017" stroke-width="1.3" />
      <path d="M8 32L125 106L242 32" stroke="#8b2017" stroke-width="1.2" />
      <path d="M8 156L92 92" stroke="#9c8e7e" stroke-width="1" />
      <path d="M242 156L158 92" stroke="#9c8e7e" stroke-width="1" />
      <circle cx="125" cy="100" r="18" fill="#c0392b" />
      <text x="125" y="104" font-family="Departure Mono, monospace" font-size="9" fill="#f5f0e8" text-anchor="middle" font-weight="bold">CN</text>
      <text x="125" y="20" font-family="Departure Mono, monospace" font-size="8" fill="#6b5e52" text-anchor="middle" letter-spacing="0.16em">PROGRAM NOTES</text>
    </svg>
  );
}

export function MarqueeArrow() {
  return (
    <svg viewBox="0 0 250 120" fill="none" xmlns="http://www.w3.org/2000/svg" class="artifact-svg">
      <path d="M8 24H160L240 60L160 96H8V24Z" fill="#1a1613" stroke="#8b2017" stroke-width="1.5" />
      <path d="M24 40H156L208 60L156 80H24V40Z" fill="#2c2420" />
      {[
        [24, 24], [48, 24], [72, 24], [96, 24], [120, 24], [144, 24], [168, 32], [190, 46], [206, 60], [190, 74], [168, 88], [144, 96], [120, 96], [96, 96], [72, 96], [48, 96], [24, 96]
      ].map(([cx, cy]) => (
        <circle cx={cx} cy={cy} r="4" fill="#d4a843" />
      ))}
      <text x="92" y="56" font-family="Departure Mono, monospace" font-size="10" fill="#e6dbc8" text-anchor="middle" letter-spacing="0.16em">THIS WAY</text>
      <text x="92" y="72" font-family="Departure Mono, monospace" font-size="8" fill="#d4a843" text-anchor="middle">TO THE SCREENING</text>
    </svg>
  );
}

export function CriticNotebook() {
  return (
    <svg viewBox="0 0 180 220" fill="none" xmlns="http://www.w3.org/2000/svg" class="artifact-svg">
      <rect x="28" y="10" width="128" height="200" rx="4" fill="#efe6d8" stroke="#8b2017" stroke-width="1.2" />
      <rect x="28" y="10" width="24" height="200" fill="#d8ccb8" />
      {[26, 48, 70, 92, 114, 136, 158, 180].map((y) => (
        <circle cx="40" cy={y} r="4" fill="#f5f0e8" stroke="#9c8e7e" stroke-width="0.7" />
      ))}
      <text x="92" y="36" font-family="Departure Mono, monospace" font-size="8" fill="#8b2017" text-anchor="middle" letter-spacing="0.18em">CRITIC NOTEBOOK</text>
      {[60, 82, 104, 126, 148, 170].map((y) => (
        <line x1="62" y1={y} x2="142" y2={y} stroke="#9c8e7e" stroke-width="0.6" />
      ))}
      <text x="66" y="76" font-family="Departure Mono, monospace" font-size="7" fill="#1a1613">"Excellent question."</text>
      <text x="66" y="120" font-family="Departure Mono, monospace" font-size="7" fill="#1a1613">"No browser tab needed."</text>
    </svg>
  );
}

export function RepertoryCalendar() {
  return (
    <svg viewBox="0 0 220 180" fill="none" xmlns="http://www.w3.org/2000/svg" class="artifact-svg">
      <rect x="10" y="20" width="200" height="150" rx="6" fill="#efe6d8" stroke="#8b2017" stroke-width="1.3" />
      <rect x="10" y="20" width="200" height="34" rx="6" fill="#c0392b" />
      <text x="110" y="41" font-family="Departure Mono, monospace" font-size="10" fill="#f5f0e8" text-anchor="middle" letter-spacing="0.2em">MARCH</text>
      {[0, 1, 2, 3, 4].map((r) =>
        [0, 1, 2, 3, 4, 5, 6].map((c) => (
          <rect x={24 + c * 26} y={66 + r * 20} width="18" height="14" rx="2" fill={r === 2 && c === 3 ? "#d4a843" : "#d8ccb8"} opacity={r === 2 && c === 3 ? 1 : 0.65} />
        ))
      )}
      <text x="109" y="120" font-family="Departure Mono, monospace" font-size="14" fill="#1a1613" text-anchor="middle" font-weight="bold">24/7</text>
      <text x="109" y="136" font-family="Departure Mono, monospace" font-size="7" fill="#6b5e52" text-anchor="middle" letter-spacing="0.14em">REPERTORY SCHEDULE</text>
    </svg>
  );
}

export function CinemaSeat() {
  return (
    <svg viewBox="0 0 160 200" fill="none" xmlns="http://www.w3.org/2000/svg" class="artifact-svg">
      <rect x="34" y="26" width="92" height="86" rx="18" fill="#c0392b" stroke="#8b2017" stroke-width="1.3" />
      <rect x="24" y="98" width="112" height="48" rx="16" fill="#d45a3b" stroke="#8b2017" stroke-width="1.3" />
      <rect x="18" y="94" width="20" height="56" rx="8" fill="#2c2420" />
      <rect x="122" y="94" width="20" height="56" rx="8" fill="#2c2420" />
      <line x1="42" y1="146" x2="34" y2="192" stroke="#2c2420" stroke-width="6" stroke-linecap="round" />
      <line x1="118" y1="146" x2="126" y2="192" stroke="#2c2420" stroke-width="6" stroke-linecap="round" />
      <text x="80" y="62" font-family="Departure Mono, monospace" font-size="8" fill="#f5f0e8" text-anchor="middle" letter-spacing="0.14em">ROW C</text>
      <text x="80" y="78" font-family="Departure Mono, monospace" font-size="18" fill="#f5f0e8" text-anchor="middle" font-weight="bold">7</text>
    </svg>
  );
}

export function AdmissionStamp() {
  return (
    <svg viewBox="0 0 150 150" fill="none" xmlns="http://www.w3.org/2000/svg" class="artifact-svg">
      <circle cx="75" cy="75" r="64" fill="#efe6d8" stroke="#8b2017" stroke-width="2" />
      <circle cx="75" cy="75" r="52" fill="none" stroke="#d4a843" stroke-width="1.2" stroke-dasharray="3 4" />
      <text x="75" y="52" font-family="Departure Mono, monospace" font-size="8" fill="#8b2017" text-anchor="middle" letter-spacing="0.18em">APPROVED</text>
      <text x="75" y="83" font-family="Departure Mono, monospace" font-size="22" fill="#1a1613" text-anchor="middle" font-weight="bold">CN</text>
      <text x="75" y="102" font-family="Departure Mono, monospace" font-size="7" fill="#6b5e52" text-anchor="middle" letter-spacing="0.14em">ADMISSION DESK</text>
    </svg>
  );
}

export function VelvetCurtain() {
  return (
    <svg viewBox="0 0 240 240" fill="none" xmlns="http://www.w3.org/2000/svg" class="artifact-svg">
      <rect x="10" y="12" width="220" height="24" rx="4" fill="#d4a843" />
      <path d="M18 36C56 56 74 88 78 228H18V36Z" fill="#8b2017" />
      <path d="M222 36C184 56 166 88 162 228H222V36Z" fill="#8b2017" />
      <path d="M60 36C92 56 104 98 106 228H78C74 88 56 56 18 36H60Z" fill="#c0392b" opacity="0.82" />
      <path d="M180 36C148 56 136 98 134 228H162C166 88 184 56 222 36H180Z" fill="#c0392b" opacity="0.82" />
      <circle cx="86" cy="132" r="6" fill="#d4a843" />
      <circle cx="154" cy="132" r="6" fill="#d4a843" />
      <path d="M86 138V182" stroke="#d4a843" stroke-width="2" />
      <path d="M154 138V182" stroke="#d4a843" stroke-width="2" />
      <text x="120" y="222" font-family="Departure Mono, monospace" font-size="7" fill="#6b5e52" text-anchor="middle" letter-spacing="0.14em">CURTAIN CALL</text>
    </svg>
  );
}

export function FilmCanister() {
  return (
    <svg viewBox="0 0 180 190" fill="none" xmlns="http://www.w3.org/2000/svg" class="artifact-svg">
      <ellipse cx="90" cy="36" rx="54" ry="16" fill="#2c2420" />
      <rect x="36" y="36" width="108" height="104" fill="#d8ccb8" stroke="#8b2017" stroke-width="1.2" />
      <ellipse cx="90" cy="140" rx="54" ry="16" fill="#c0392b" />
      <ellipse cx="90" cy="36" rx="42" ry="11" fill="#1a1613" />
      <circle cx="90" cy="36" r="6" fill="#d4a843" />
      <text x="90" y="82" font-family="Departure Mono, monospace" font-size="14" fill="#1a1613" text-anchor="middle" font-weight="bold">35MM</text>
      <text x="90" y="102" font-family="Departure Mono, monospace" font-size="8" fill="#6b5e52" text-anchor="middle">ARCHIVE PRINT</text>
      <text x="90" y="124" font-family="Departure Mono, monospace" font-size="7" fill="#8b2017" text-anchor="middle" letter-spacing="0.12em">HANDLE GENTLY</text>
    </svg>
  );
}

export function BoxOfficeLedger() {
  return (
    <svg viewBox="0 0 230 190" fill="none" xmlns="http://www.w3.org/2000/svg" class="artifact-svg">
      <rect x="8" y="8" width="214" height="174" rx="4" fill="#efe6d8" stroke="#8b2017" stroke-width="1.2" />
      <rect x="8" y="8" width="214" height="24" rx="4" fill="#1a1613" />
      <text x="116" y="23" font-family="Departure Mono, monospace" font-size="8" fill="#d4a843" text-anchor="middle" letter-spacing="0.16em">BOX OFFICE LEDGER</text>
      <line x1="32" y1="50" x2="32" y2="166" stroke="#9c8e7e" stroke-width="0.8" />
      <line x1="122" y1="50" x2="122" y2="166" stroke="#9c8e7e" stroke-width="0.8" />
      <line x1="178" y1="50" x2="178" y2="166" stroke="#9c8e7e" stroke-width="0.8" />
      {[50, 72, 94, 116, 138, 160].map((y) => (
        <line x1="18" y1={y} x2="212" y2={y} stroke="#9c8e7e" stroke-width="0.6" />
      ))}
      <text x="22" y="66" font-family="Departure Mono, monospace" font-size="7" fill="#1a1613">Passes</text>
      <text x="132" y="66" font-family="Departure Mono, monospace" font-size="7" fill="#1a1613">Sold</text>
      <text x="186" y="66" font-family="Departure Mono, monospace" font-size="7" fill="#1a1613">House</text>
      <text x="22" y="110" font-family="Departure Mono, monospace" font-size="7" fill="#1a1613">Matinee</text>
      <text x="132" y="110" font-family="Departure Mono, monospace" font-size="7" fill="#1a1613">47</text>
      <text x="186" y="110" font-family="Departure Mono, monospace" font-size="7" fill="#1a1613">A</text>
      <text x="22" y="132" font-family="Departure Mono, monospace" font-size="7" fill="#1a1613">Midnight</text>
      <text x="132" y="132" font-family="Departure Mono, monospace" font-size="7" fill="#1a1613">24/7</text>
      <text x="186" y="132" font-family="Departure Mono, monospace" font-size="7" fill="#1a1613">C</text>
    </svg>
  );
}
