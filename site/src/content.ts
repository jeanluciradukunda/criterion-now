export type DownloadLink = {
  label: string;
  href: string;
  meta: string;
};

export type FeaturePanel = {
  title: string;
  eyebrow: string;
  body: string;
  stats: string[];
  accent: string;
  asset: string;
};

export type AsciiProgramRow = {
  stub: string;
  program: string;
  showtime: string;
  house: string;
  status: string;
  highlight?: boolean;
};

export type GalleryFrame = {
  title: string;
  caption: string;
  kind: "image";
  src: string;
  alt: string;
};

export const downloadLinks: DownloadLink[] = [
  {
    label: "DOWNLOAD APP",
    href: "#availability",
    meta: "macOS 14+ · unsigned beta"
  },
  {
    label: "VIEW SOURCE",
    href: "#source",
    meta: "Swift · SwiftUI · AppKit"
  }
];

export const programRows: AsciiProgramRow[] = [
  {
    stub: "I",
    program: "Now Playing — Live Stream",
    showtime: "Continuous",
    house: "24/7",
    status: "● NOW"
  },
  {
    stub: "II",
    program: "Soundtrack Discovery",
    showtime: "On Demand",
    house: "Mix",
    status: "● VERIFIED",
    highlight: true
  },
  {
    stub: "III",
    program: "My List — Flip Cards",
    showtime: "Anytime",
    house: "Lib",
    status: "CACHED"
  },
  {
    stub: "IV",
    program: "Viewing History",
    showtime: "Rolling",
    house: "Log",
    status: "RECORDING"
  },
  {
    stub: "V",
    program: "Cinema World Globe",
    showtime: "Browse",
    house: "Map",
    status: "CHARTED"
  }
];

export const featurePanels: FeaturePanel[] = [
  {
    eyebrow: "NOW PLAYING",
    title: "Knows what's on before you open the browser.",
    body:
      "Connects to the live Criterion 24/7 stream and shows you the current film with rich details — poster, director, runtime, and a real-time progress bar that ticks every second. Get notified when the next film starts.",
    stats: ["Rich film details", "Live progress ticker", "Film change notifications"],
    accent: "amber",
    asset: "/assets/program-slip.svg"
  },
  {
    eyebrow: "SOUNDTRACK",
    title: "Five sources. One weighted answer.",
    body:
      "Discovers the film's soundtrack by checking Wikidata, MusicBrainz, Discogs, iTunes, and Last.fm simultaneously. Scores every result across six dimensions so you only see verified matches, not guesses.",
    stats: ["5 sources in parallel", "6-dimension scoring", "Swipeable cover carousel"],
    accent: "flux",
    asset: "/assets/playlist-receipt.svg"
  },
  {
    eyebrow: "LIBRARY",
    title: "Your Criterion list as flip cards, not a spreadsheet.",
    body:
      "Sign in once and your My List loads directly into the app. Browse your saved films as flip cards with search, decade filters, and country filters. Explore collections. Everything is cached locally so it's instant after the first load.",
    stats: ["Instant local cache", "Search + filter chips", "Collection drill-down"],
    accent: "foam",
    asset: "/assets/film-can-label.svg"
  },
  {
    eyebrow: "HISTORY",
    title: "The only Criterion 24/7 viewing log that exists.",
    body:
      "Automatically keeps track of every film that plays on the 24/7 stream while you have the app open. See what screened today, yesterday, or last week in a clean timeline with viewing stats.",
    stats: ["Automatic tracking", "Day-grouped timeline", "Director + film stats"],
    accent: "clay",
    asset: "/assets/timeline-spine.svg"
  },
  {
    eyebrow: "GEOGRAPHY",
    title: "See where your films come from.",
    body:
      "A 3D globe that maps your library by country of origin. Poster clusters sit on the globe surface with callout cards showing how your collection spans the world. Break it down by director and decade.",
    stats: ["Interactive 3D globe", "Country callout cards", "Director + decade breakdown"],
    accent: "pumpkin",
    asset: "/assets/world-grid.svg"
  }
];

export const galleryFrames: GalleryFrame[] = [
  {
    title: "Now Playing + Soundtrack",
    caption: "The menu bar popover showing the current film, progress bar, and soundtrack tab with album artwork and track listing.",
    kind: "image",
    src: "/assets/library-shot-01.png",
    alt: "Criterion Now menu bar popover showing film details and soundtrack"
  },
  {
    title: "Library Flip Cards",
    caption: "Browsing My List as flip cards with search bar and decade/country filter chips below the carousel.",
    kind: "image",
    src: "/assets/library-shot-02.png",
    alt: "Library flip card browser with poster and film details"
  },
  {
    title: "Settings + Scoring Radar",
    caption: "Developer settings showing the soundtrack scoring radar chart, API key management, and app metrics.",
    kind: "image",
    src: "/assets/library-shot-03.png",
    alt: "Settings panel with radar chart and metrics"
  }
];

export const footerFacts = [
  "macOS 14+",
  "SwiftUI · AppKit · SceneKit",
  "5 music APIs",
  "Local-first cache",
  "Criterion 24/7 companion"
];
