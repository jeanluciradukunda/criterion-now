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
