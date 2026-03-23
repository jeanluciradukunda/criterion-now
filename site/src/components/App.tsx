import { For, createSignal, onCleanup, onMount } from "solid-js";
import { downloadLinks, featurePanels, footerFacts, galleryFrames, programRows } from "../content";
import { DraggableArtifact } from "./DraggableArtifact";
import { TicketStub, FilmCanLabel, CueSheet, ScreeningProgram, TimelineStrip, DirectorSlate, ProjectorReel, SeasonPass, PopcornBox, TornTicket, FilmRating, Filmstrip3D, VinylRecord, Megaphone, DirectorsChair, FilmAward, OscarStatuette, TheatreFacade, BoxOfficeBooth, JanusCard, FestivalLaurels, UsherFlashlight, TicketStrip, ProjectionLens, PressKitFolder, ProgramEnvelope, MarqueeArrow, CriticNotebook, RepertoryCalendar, CinemaSeat, AdmissionStamp, VelvetCurtain, FilmCanister, BoxOfficeLedger } from "./CinemaArtifacts";
import { featureDiagrams } from "./FeatureDiagrams";
import { AppMockup } from "./AppMockup";

const TITLE = "CRITERION NOW";

const FAQ_ITEMS = [
  { q: "Is this app stable yet?", a: "Not fully. Criterion Now is still in public beta. The core workflow is usable, but the UI, metadata matching, soundtrack discovery, and install flow are still being refined in the open." },
  { q: "Do I need a Criterion Channel subscription?", a: "Yes. Criterion Now is a companion app — it connects to your existing Criterion Channel account to show what's streaming on the 24/7 channel, manage your My List, and track viewing history." },
  { q: "Is my data sent anywhere?", a: "No. Everything stays on your Mac. Film data, viewing history, library cache, and settings are stored locally in ~/Library/Application Support/CriterionNow/ as plain JSON files. No analytics, no cloud, no telemetry." },
  { q: "How does soundtrack matching work?", a: "When a film is detected, five music sources are queried in parallel — Wikidata, MusicBrainz, Discogs, iTunes, and Last.fm. Each result is scored across six dimensions (title match, artist match, release year, track count, source trust, keyword relevance) with configurable weights. Only results above the confidence threshold are shown." },
  { q: "Will it flag my Criterion account for multiple devices?", a: "No. The app shares a single browser session with the stream, so Criterion sees one device. It's the same as having one Safari tab open." },
  { q: "What macOS version do I need?", a: "macOS 14 (Sonoma) or later. The app uses SwiftUI features and APIs introduced in macOS 14. It runs natively on both Apple Silicon and Intel Macs." },
  { q: "Why is the app unsigned?", a: "This is a personal, non-commercial project and is not distributed through the Mac App Store. macOS will show a security prompt the first time you open it — see the installation guide above for how to allow it." },
];

export function App() {
  const [title, setTitle] = createSignal(TITLE);
  const [navVisible, setNavVisible] = createSignal(false);
  const year = new Date().getFullYear();

  onMount(() => {
    // Title glitch
    if (!window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
      const handle = window.setInterval(() => {
        const chars = [...TITLE];
        const idx = Math.floor(Math.random() * chars.length);
        if (chars[idx] !== " ") chars[idx] = " ";
        setTitle(chars.join(""));
        window.setTimeout(() => setTitle(TITLE), 60);
      }, 4000);
      onCleanup(() => window.clearInterval(handle));
    }

    // Scroll reveal via IntersectionObserver
    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            entry.target.classList.add("visible");
          }
        });
      },
      { threshold: 0.1, rootMargin: "0px 0px -40px 0px" }
    );

    document.querySelectorAll(".reveal").forEach((el) => observer.observe(el));
    onCleanup(() => observer.disconnect());

    // Sticky nav — show after scrolling past hero
    const heroEl = document.querySelector(".hero-shell");
    if (heroEl) {
      const navObserver = new IntersectionObserver(
        ([entry]) => setNavVisible(!entry.isIntersecting),
        { threshold: 0 }
      );
      navObserver.observe(heroEl);
      onCleanup(() => navObserver.disconnect());
    }
  });

  return (
    <main>
      {/* ═══════ STICKY NAV ═══════ */}
      <nav class={`sticky-nav ${navVisible() ? "visible" : ""}`}>
        <a href="#program">Program</a>
        <a href="#features">Features</a>
        <a href="#how-it-works">How It Works</a>
        <a href="#install">Install</a>
        <a href="#gallery">Gallery</a>
        <a href="#faq">FAQ</a>
      </nav>

      {/* ═══════ HERO — big title + live app mockup ═══════ */}
      <section class="hero-shell">
        <div class="maxwidth">
          <div class="hero-content">
            <div class="hero-text">
              <div class="brand-line">
                <img src={`${import.meta.env.BASE_URL}assets/criterion-c.svg`} alt="" class="brand-logo" />
                <p class="kicker">macOS Menu Bar Companion for the Criterion Channel</p>
              </div>
              <div class="hero-headline">
                <h1>{title()}</h1>
              </div>
              <div class="hero-beta">
                <span class="beta-pill">PUBLIC BETA</span>
                <p>Shipping fast in the open. Expect rough edges, UI changes, and the occasional broken match while the app settles.</p>
              </div>
              <p class="hero-desc">
                A companion for the Criterion Channel that puts everything in one place — what's playing now,
                the soundtrack, your saved library, your viewing history, and where your films come from.
                All from your menu bar.
              </p>
              <menu class="hero-menu">
                <For each={downloadLinks}>
                  {(link) => (
                    <a href={link.href}>
                      <span>{link.label}</span>
                      <small>{link.meta}</small>
                    </a>
                  )}
                </For>
              </menu>
            </div>
            <AppMockup />
          </div>
        </div>

        {/* Draggable cinema artifacts */}
        <div class="artifact-field">
          <DraggableArtifact class="artifact-ticket wobble-hint" rotation={-3} parallax={0.04} style="top: 2rem; right: 4rem;">
            <TicketStub />
          </DraggableArtifact>
          <DraggableArtifact class="artifact-popcorn wobble-hint" rotation={6} parallax={0.07} style="top: 6rem; left: -1rem;">
            <PopcornBox />
          </DraggableArtifact>
          <DraggableArtifact class="artifact-torn wobble-hint" rotation={-5} parallax={0.03} style="bottom: 3rem; left: 4rem;">
            <TornTicket />
          </DraggableArtifact>
          <DraggableArtifact class="artifact-slate wobble-hint" rotation={-2} parallax={0.06} style="bottom: 1rem; right: 14rem;">
            <DirectorSlate />
          </DraggableArtifact>
          <DraggableArtifact class="artifact-megaphone wobble-hint" rotation={8} parallax={0.05} style="top: 14rem; right: 1rem;">
            <Megaphone />
          </DraggableArtifact>
        </div>
      </section>

      {/* ═══════ SCREENING BOARD — cinema marquee ═══════ */}
      <section class="marquee-shell" id="program">
        <div class="maxwidth">
          <div class="marquee-header reveal">
            <div class="marquee-bulbs">
              <span /><span /><span /><span /><span />
            </div>
            <h2 class="marquee-title">Tonight's Program</h2>
            <div class="marquee-bulbs">
              <span /><span /><span /><span /><span />
            </div>
          </div>
          <div class="marquee-board">
            <div class="marquee-row marquee-row-header reveal">
              <span class="marquee-col col-num">#</span>
              <span class="marquee-col col-feature">Feature</span>
              <span class="marquee-col col-time">Showtime</span>
              <span class="marquee-col col-house">House</span>
              <span class="marquee-col col-status">Status</span>
            </div>
            <For each={programRows}>
              {(row, i) => (
                <div class={`marquee-row reveal reveal-delay-${i() + 1}`} classList={{ "marquee-active": row.highlight }}>
                  <span class="marquee-col col-num">{row.stub}</span>
                  <span class="marquee-col col-feature">{row.program}</span>
                  <span class="marquee-col col-time">{row.showtime}</span>
                  <span class="marquee-col col-house">{row.house}</span>
                  <span class="marquee-col col-status">{row.status}</span>
                </div>
              )}
            </For>
          </div>
          <p class="marquee-footer reveal">All features subject to change · No intermission · Continuous program</p>
        </div>
      </section>

      {/* ═══════ FEATURES ═══════ */}
      <section class="feature-shell" id="features">
        <div class="maxwidth">
          <div class="section-head reveal">
            <p class="kicker">What You Get</p>
            <h2>Five instruments in one menu bar.</h2>
          </div>
          <div class="feature-grid">
            <For each={featurePanels}>
              {(panel, i) => (
                <article class={`feature-panel accent-${panel.accent} reveal reveal-delay-${(i() % 3) + 1}`}>
                  <div>
                    <p class="eyebrow">{panel.eyebrow}</p>
                    <h3>{panel.title}</h3>
                    <p>{panel.body}</p>
                    <ul>
                      <For each={panel.stats}>{(item) => <li>{item}</li>}</For>
                    </ul>
                  </div>
                  <div class="feature-visual">
                    {featureDiagrams[panel.accent]?.() ?? <img src={panel.asset} alt="" />}
                  </div>
                </article>
              )}
            </For>
          </div>
        </div>

        <div class="artifact-field">
          <DraggableArtifact class="artifact-cue wobble-hint" rotation={-2} parallax={0.06} style="top: 4rem; left: -2rem;">
            <CueSheet />
          </DraggableArtifact>
          <DraggableArtifact class="artifact-can wobble-hint" rotation={5} parallax={0.04} style="bottom: 6rem; right: 0rem;">
            <FilmCanLabel />
          </DraggableArtifact>
          <DraggableArtifact class="artifact-reel wobble-hint" rotation={-1} parallax={0.08} style="top: 50%; left: -3rem;">
            <ProjectorReel />
          </DraggableArtifact>
          <DraggableArtifact class="artifact-vinyl wobble-hint" rotation={3} parallax={0.05} style="top: 20%; right: -2rem;">
            <VinylRecord />
          </DraggableArtifact>
          <DraggableArtifact class="artifact-filmstrip wobble-hint" rotation={-4} parallax={0.03} style="bottom: 20%; left: 1rem;">
            <Filmstrip3D />
          </DraggableArtifact>
          <DraggableArtifact class="artifact-chair wobble-hint" rotation={2} parallax={0.07} style="top: 35%; right: 1rem;">
            <DirectorsChair />
          </DraggableArtifact>
          <DraggableArtifact class="artifact-program wobble-hint" rotation={-3} parallax={0.04} style="bottom: 35%; left: -1rem;">
            <ScreeningProgram />
          </DraggableArtifact>
        </div>
      </section>

      {/* ═══════ EDITORIAL — dark band ═══════ */}
      <section class="editorial-shell" id="how-it-works">
        <div class="maxwidth editorial-grid">
          <div class="section-head reveal">
            <p class="kicker">How It Works</p>
            <h2>Local data. No cloud. One Criterion session.</h2>
          </div>
          <div class="editorial-stack">
            <article class="paper-card reveal">
              <p class="eyebrow">What Ships</p>
              <p>
                See what's playing right now with a real-time progress bar. Find the soundtrack
                instantly, verified across six scoring dimensions. Browse your saved library as
                flip cards with search and filters. Track your viewing history in a timeline. Explore
                your cinema world on a 3D globe organized by country.
              </p>
            </article>
            <article class="paper-card reveal reveal-delay-2">
              <p class="eyebrow">Technical Stack</p>
              <ul class="paper-list">
                <li>macOS 14+ / SwiftUI / AppKit / SceneKit</li>
                <li>Menu bar resident — no Dock icon</li>
                <li>Local JSON persistence, no cloud</li>
                <li>Wikidata + MusicBrainz + Discogs + iTunes + Last.fm</li>
                <li>6-dimension weighted scoring with configurable radar</li>
              </ul>
            </article>
          </div>
        </div>
        <div class="artifact-field">
          <DraggableArtifact class="artifact-strip wobble-hint" rotation={1} parallax={0.05} style="bottom: 2rem; right: 4rem;">
            <TimelineStrip />
          </DraggableArtifact>
          <DraggableArtifact class="artifact-pass wobble-hint" rotation={-3} parallax={0.06} style="top: 3rem; left: 2rem;">
            <SeasonPass />
          </DraggableArtifact>
          <DraggableArtifact class="artifact-rating wobble-hint" rotation={7} parallax={0.04} style="bottom: 4rem; left: 6rem;">
            <FilmRating />
          </DraggableArtifact>
          <DraggableArtifact class="artifact-award wobble-hint" rotation={-5} parallax={0.07} style="top: 1rem; right: 2rem;">
            <FilmAward />
          </DraggableArtifact>
        </div>
      </section>

      {/* ═══════ ORIGIN STORY ═══════ */}
      <section class="origin-shell">
        <div class="maxwidth origin-content reveal">
          <blockquote class="origin-quote">
            "I kept a browser tab open to the Criterion 24/7 stream and found myself
            constantly switching windows to check what was playing, searching for
            soundtracks separately, losing track of what I'd already watched. So I built
            a menu bar app that does all of that without leaving what I'm working on."
          </blockquote>
          <p class="origin-caption">— The entire reason this exists</p>
        </div>
        <div class="artifact-field">
          <DraggableArtifact class="artifact-theatre wobble-hint" rotation={-3} parallax={0.05} style="top: 1.5rem; left: 2rem;">
            <TheatreFacade />
          </DraggableArtifact>
          <DraggableArtifact class="artifact-janus wobble-hint" rotation={5} parallax={0.04} style="top: 2rem; right: 4rem;">
            <JanusCard />
          </DraggableArtifact>
          <DraggableArtifact class="artifact-laurels wobble-hint" rotation={-4} parallax={0.06} style="bottom: 1rem; right: 16rem;">
            <FestivalLaurels />
          </DraggableArtifact>
        </div>
      </section>

      {/* ═══════ INSTALL GUIDE ═══════ */}
      <section class="install-shell" id="install">
        <div class="maxwidth">
          <div class="section-head reveal">
            <p class="kicker">Opening Night</p>
            <h2>Installation in four acts.</h2>
          </div>
          <div class="install-grid">
            <div class="install-step reveal reveal-delay-1">
              <span class="install-step-num">ACT I</span>
              <h4>Download</h4>
              <p>Grab the latest public beta release from the downloads section. It's a single .app bundle — no installer needed.</p>
            </div>
            <div class="install-step reveal reveal-delay-2">
              <span class="install-step-num">ACT II</span>
              <h4>Move to Applications</h4>
              <p>Drag Criterion Now.app into your Applications folder. This is optional but keeps things tidy.</p>
            </div>
            <div class="install-step reveal reveal-delay-3">
              <span class="install-step-num">ACT III</span>
              <h4>Open with Permission</h4>
              <p>Since the app is unsigned, macOS will block it on first launch. Right-click the app and choose "Open", then click "Open" in the dialog.</p>
              <code>Right-click → Open → Open</code>
            </div>
            <div class="install-step reveal reveal-delay-4">
              <span class="install-step-num">ACT IV</span>
              <h4>Curtain Up</h4>
              <p>Look for the Criterion Now icon in your menu bar. Click it to open the popover. Stream once to log in to Criterion, then explore everything.</p>
            </div>
          </div>
        </div>
        <div class="artifact-field">
          <DraggableArtifact class="artifact-boxoffice wobble-hint" rotation={-4} parallax={0.04} style="top: 1rem; left: 1rem;">
            <BoxOfficeBooth />
          </DraggableArtifact>
          <DraggableArtifact class="artifact-oscar wobble-hint" rotation={6} parallax={0.06} style="top: 1rem; right: 6rem;">
            <OscarStatuette />
          </DraggableArtifact>
          <DraggableArtifact class="artifact-flashlight wobble-hint" rotation={-5} parallax={0.05} style="bottom: 1rem; left: 10rem;">
            <UsherFlashlight />
          </DraggableArtifact>
          <DraggableArtifact class="artifact-ticketstrip wobble-hint" rotation={7} parallax={0.07} style="bottom: 1rem; right: 6rem;">
            <TicketStrip />
          </DraggableArtifact>
        </div>
      </section>

      {/* ═══════ GALLERY ═══════ */}
      <section class="gallery-shell" id="gallery">
        <div class="maxwidth gallery-grid">
          <div class="section-head reveal">
            <p class="kicker">Interface Studies</p>
            <h2>Original artwork of the real app.</h2>
          </div>
          <For each={galleryFrames}>
            {(frame, i) => (
              <article class={`gallery-card reveal reveal-delay-${(i() % 3) + 1}`}>
                <img src={frame.src} alt={frame.alt} />
                <div class="gallery-caption">
                  <p class="eyebrow">{frame.title}</p>
                  <p>{frame.caption}</p>
                </div>
              </article>
            )}
          </For>
        </div>
        <div class="artifact-field">
          <DraggableArtifact class="artifact-lens wobble-hint" rotation={-6} parallax={0.05} style="top: 4rem; left: 1rem;">
            <ProjectionLens />
          </DraggableArtifact>
          <DraggableArtifact class="artifact-presskit wobble-hint" rotation={4} parallax={0.03} style="top: 8rem; right: 1rem;">
            <PressKitFolder />
          </DraggableArtifact>
          <DraggableArtifact class="artifact-envelope wobble-hint" rotation={-2} parallax={0.06} style="bottom: 2rem; left: 4rem;">
            <ProgramEnvelope />
          </DraggableArtifact>
          <DraggableArtifact class="artifact-arrow wobble-hint" rotation={5} parallax={0.04} style="bottom: 2rem; right: 4rem;">
            <MarqueeArrow />
          </DraggableArtifact>
        </div>
      </section>

      {/* ═══════ FAQ ═══════ */}
      <section class="faq-shell" id="faq">
        <div class="maxwidth">
          <div class="section-head reveal">
            <p class="kicker">Audience Questions</p>
            <h2>Before you take your seat.</h2>
          </div>
          <div class="faq-list">
            <For each={FAQ_ITEMS}>
              {(item) => <FAQItem question={item.q} answer={item.a} />}
            </For>
          </div>
        </div>
        <div class="artifact-field">
          <DraggableArtifact class="artifact-notebook wobble-hint" rotation={-3} parallax={0.05} style="top: 2rem; left: 0.5rem;">
            <CriticNotebook />
          </DraggableArtifact>
          <DraggableArtifact class="artifact-calendar wobble-hint" rotation={6} parallax={0.07} style="top: 2rem; right: 4rem;">
            <RepertoryCalendar />
          </DraggableArtifact>
          <DraggableArtifact class="artifact-seat wobble-hint" rotation={-5} parallax={0.04} style="bottom: 1rem; left: 7rem;">
            <CinemaSeat />
          </DraggableArtifact>
          <DraggableArtifact class="artifact-stamp wobble-hint" rotation={5} parallax={0.06} style="bottom: 2rem; right: 8rem;">
            <AdmissionStamp />
          </DraggableArtifact>
        </div>
      </section>

      {/* ═══════ FOOTER ═══════ */}
      <footer class="site-footer">
        <div class="maxwidth footer-grid">
          <div>
            <p class="kicker">Criterion Now / {year}</p>
            <h2>One page. One app. The channel, readable.</h2>
          </div>
          <div class="footer-meta">
            <ul class="footer-facts">
              <For each={footerFacts}>{(fact) => <li>{fact}</li>}</For>
            </ul>
            <div class="footer-links">
              <a href="https://github.com/jeanluciradukunda/criterion-now/releases/latest">DOWNLOAD</a>
              <a href="https://github.com/jeanluciradukunda/criterion-now">SOURCE</a>
            </div>
            <p class="commentary">
              Swift, SwiftUI, AppKit, SceneKit. Five music APIs scored in parallel.
              One macOS menu bar. No Electron.
            </p>
          </div>
        </div>
        <div class="maxwidth footer-credits">
          <p class="kicker">Design Inspiration</p>
          <ul class="credits-list">
            <li><a href="https://departuremono.com/" target="_blank" rel="noopener">Departure Mono</a> — typography + editorial aesthetic</li>
            <li><a href="https://www.makingsoftware.com/" target="_blank" rel="noopener">Making Software</a> — technical SVG diagrams + generous whitespace</li>
            <li><a href="https://flowingdata.com/" target="_blank" rel="noopener">FlowingData</a> — warm earthy color palette</li>
            <li><a href="https://ui.aceternity.com/components/timeline" target="_blank" rel="noopener">Aceternity UI</a> — timeline scroll beam patterns</li>
            <li><a href="https://github.com/ThasianX/ElegantTimeline-SwiftUI" target="_blank" rel="noopener">ElegantTimeline</a> — SwiftUI timeline interaction</li>
          </ul>
        </div>
        <div class="maxwidth footer-legal">
          <p>
            Criterion Now is an independent, non-commercial, open-source project released under the
            {" "}<a href="https://opensource.org/licenses/MIT" target="_blank" rel="noopener">MIT License</a>.
            It is not affiliated with, endorsed by, or connected to The Criterion Collection, The Criterion Channel,
            Janus Films, or any of their subsidiaries. "Criterion" and the Criterion logo are trademarks of
            The Criterion Collection. Film metadata is provided by
            {" "}<a href="https://www.themoviedb.org/" target="_blank" rel="noopener">TMDB</a> and used
            in accordance with their API terms of use. Soundtrack data is sourced from
            {" "}<a href="https://musicbrainz.org/" target="_blank" rel="noopener">MusicBrainz</a>,
            {" "}<a href="https://www.discogs.com/" target="_blank" rel="noopener">Discogs</a>,
            {" "}<a href="https://www.last.fm/" target="_blank" rel="noopener">Last.fm</a>,
            {" "}<a href="https://www.wikidata.org/" target="_blank" rel="noopener">Wikidata</a>,
            and the iTunes Search API. This project is built for personal use and educational purposes.
          </p>
        </div>
        <div class="artifact-field">
          <DraggableArtifact class="artifact-curtain wobble-hint" rotation={2} parallax={0.05} style="top: 2rem; right: 1rem;">
            <VelvetCurtain />
          </DraggableArtifact>
          <DraggableArtifact class="artifact-canister wobble-hint" rotation={-5} parallax={0.04} style="bottom: 7rem; left: 2rem;">
            <FilmCanister />
          </DraggableArtifact>
          <DraggableArtifact class="artifact-ledger wobble-hint" rotation={7} parallax={0.06} style="bottom: 6rem; right: 10rem;">
            <BoxOfficeLedger />
          </DraggableArtifact>
        </div>
      </footer>
    </main>
  );
}

// ═══════ FAQ Accordion Item ═══════

function FAQItem(props: { question: string; answer: string }) {
  const [open, setOpen] = createSignal(false);

  return (
    <div class="faq-item reveal" classList={{ open: open() }}>
      <button type="button" class="faq-question" onClick={() => setOpen((o) => !o)}>
        {props.question}
        <span class="faq-chevron">▸</span>
      </button>
      <div class="faq-answer">
        <p>{props.answer}</p>
      </div>
    </div>
  );
}
