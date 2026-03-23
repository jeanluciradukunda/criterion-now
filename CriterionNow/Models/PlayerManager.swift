import SwiftUI
import WebKit
import Combine

enum PlayerMode: String {
    case off       // Not streaming
    case video     // Video + audio
    case radio     // Audio only, show poster
}

enum PlayerDock: String {
    case docked    // Inside the menu bar popover
    case undocked  // Floating mini-player window
}

@MainActor
class PlayerManager: ObservableObject {
    @Published var mode: PlayerMode = .off
    @Published var dock: PlayerDock = .docked
    @Published var volume: Double = 0.8
    @Published var isLoading = false
    @Published var isLoggedIn = false
    @Published var subtitlesEnabled = true
    @Published var audioLevels: [Float] = []

    let webView: WKWebView

    private let streamURL = URL(string: "https://www.criterionchannel.com/events/criterion-24-7")!
    private var volumeObserver: AnyCancellable?
    private var navigationDelegate: PlayerNavigationDelegate?
    private var audioMessageHandler: AudioMessageHandler?

    init() {
        // Configure WKWebView with scripts that inject into ALL frames (including iframes)
        let config = WKWebViewConfiguration()
        config.allowsAirPlayForMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.preferences.isElementFullscreenEnabled = false
        config.websiteDataStore = .default()

        // Volume control script that runs in ALL frames (main + iframes)
        let volumeScript = WKUserScript(
            source: """
            // Set up a message listener for volume changes
            window.__criterionVolume = 0.8;
            setInterval(function() {
                document.querySelectorAll('video, audio').forEach(function(el) {
                    if (el.volume !== window.__criterionVolume) {
                        el.volume = window.__criterionVolume;
                    }
                });
            }, 500);
            """,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: false  // This is the key — runs in iframes too
        )
        config.userContentController.addUserScript(volumeScript)

        // Audio analyser script — connects Web Audio API AnalyserNode to video/audio elements
        let analyserScript = WKUserScript(
            source: """
            (function() {
                if (window.__criterionAnalyserSetup) return;
                window.__criterionAnalyserSetup = true;

                var audioCtx = null;
                var analyser = null;
                var dataArray = null;
                var connectedElements = new WeakSet();

                function setupAnalyser(mediaEl) {
                    if (connectedElements.has(mediaEl)) return;
                    try {
                        if (!audioCtx) {
                            audioCtx = new (window.AudioContext || window.webkitAudioContext)();
                            analyser = audioCtx.createAnalyser();
                            analyser.fftSize = 128;
                            analyser.smoothingTimeConstant = 0.8;
                            analyser.connect(audioCtx.destination);
                            dataArray = new Uint8Array(analyser.frequencyBinCount);
                        }
                        var source = audioCtx.createMediaElementSource(mediaEl);
                        source.connect(analyser);
                        connectedElements.add(mediaEl);
                    } catch(e) {}
                }

                function sendLevels() {
                    if (!analyser || !dataArray) return;
                    analyser.getByteFrequencyData(dataArray);
                    // Send 32 frequency bins to Swift
                    var bins = [];
                    var binSize = Math.floor(dataArray.length / 32);
                    for (var i = 0; i < 32; i++) {
                        var sum = 0;
                        for (var j = 0; j < binSize; j++) {
                            sum += dataArray[i * binSize + j];
                        }
                        bins.push(Math.round(sum / binSize));
                    }
                    window.webkit.messageHandlers.audioLevels.postMessage(bins);
                }

                setInterval(function() {
                    document.querySelectorAll('video, audio').forEach(setupAnalyser);
                    sendLevels();
                }, 80);
            })();
            """,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: false
        )
        config.userContentController.addUserScript(analyserScript)

        // Register message handler for audio levels
        let handler = AudioMessageHandler()
        config.userContentController.add(handler, name: "audioLevels")

        let wv = WKWebView(frame: .zero, configuration: config)
        wv.allowsBackForwardNavigationGestures = false
        wv.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 14_0) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Safari/605.1.15"
        self.webView = wv
        self.audioMessageHandler = handler

        // Wire up audio levels from JS → Swift
        handler.onLevels = { [weak self] levels in
            Task { @MainActor in
                self?.audioLevels = levels
            }
        }

        // Set up navigation delegate for re-injecting after page loads
        let navDelegate = PlayerNavigationDelegate()
        self.navigationDelegate = navDelegate
        wv.navigationDelegate = navDelegate

        // Sync volume changes to all frames
        volumeObserver = $volume
            .debounce(for: .milliseconds(50), scheduler: RunLoop.main)
            .sink { [weak self] newVolume in
                self?.setWebViewVolume(newVolume)
            }

        navDelegate.onPageLoad = { [weak self] in
            // Re-inject player controls after each navigation
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self?.injectPlayerControls()
                self?.applySubtitles()
                self?.injectAudioAnalyser()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self?.injectPlayerControls()
                self?.applySubtitles()
                self?.injectAudioAnalyser()
            }
        }
    }

    func startStreaming() {
        guard mode == .off else { return }
        isLoading = true
        mode = .video
        let request = URLRequest(url: streamURL)
        webView.load(request)

        // Inject JS progressively as page loads
        for delay in [2.0, 4.0, 6.0, 8.0] {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                self?.injectPlayerControls()
                self?.applySubtitles()
                self?.injectAudioAnalyser()
                if delay >= 6.0 {
                    self?.isLoading = false
                }
            }
        }
    }

    func stopStreaming() {
        mode = .off
        dock = .docked
        audioLevels = []
        webView.loadHTMLString("<html><body style='background:black'></body></html>", baseURL: nil)
        MiniPlayerWindowController.shared.hide()
    }

    func toggleRadioMode() {
        switch mode {
        case .video:
            mode = .radio
        case .radio:
            mode = .video
        case .off:
            mode = .radio
            startStreaming()
            mode = .radio
        }
    }

    func toggleDock() {
        dock = (dock == .docked) ? .undocked : .docked
    }

    func toggleSubtitles() {
        subtitlesEnabled.toggle()
        applySubtitles()
    }

    func applySubtitles() {
        let mode = subtitlesEnabled ? "'showing'" : "'hidden'"
        let js = """
        (function() {
            var video = document.querySelector('video');
            if (video && video.textTracks) {
                for (var i = 0; i < video.textTracks.length; i++) {
                    video.textTracks[i].mode = \(mode);
                }
            }
            document.querySelectorAll('iframe').forEach(function(f) {
                try {
                    var v = f.contentDocument?.querySelector('video');
                    if (v && v.textTracks) {
                        for (var i = 0; i < v.textTracks.length; i++) {
                            v.textTracks[i].mode = \(mode);
                        }
                    }
                } catch(e) {}
            });
        })();
        """
        webView.evaluateJavaScript(js)
    }

    func setWebViewVolume(_ vol: Double) {
        // Update volume in main frame AND all iframes
        let js = """
        window.__criterionVolume = \(vol);
        document.querySelectorAll('video, audio').forEach(function(el) { el.volume = \(vol); });

        // Also try to reach into iframes (same-origin only, but worth trying)
        document.querySelectorAll('iframe').forEach(function(f) {
            try {
                f.contentWindow.postMessage({type: 'setVolume', volume: \(vol)}, '*');
                if (f.contentDocument) {
                    f.contentDocument.querySelectorAll('video, audio').forEach(function(el) { el.volume = \(vol); });
                    f.contentWindow.__criterionVolume = \(vol);
                }
            } catch(e) {}
        });
        """
        webView.evaluateJavaScript(js)

        // Also evaluate in all frames via the user script approach
        let frameJS = "window.__criterionVolume = \(vol); document.querySelectorAll('video, audio').forEach(function(el) { el.volume = \(vol); });"
        webView.evaluateJavaScript(frameJS, in: nil, in: .defaultClient)
    }

    /// Re-inject audio analyser after navigations (the user script may not survive SPA transitions)
    func injectAudioAnalyser() {
        let js = """
        (function() {
            if (window.__criterionAnalyserSetup) return;
            window.__criterionAnalyserSetup = true;

            var audioCtx = null;
            var analyser = null;
            var dataArray = null;
            var connectedElements = new WeakSet();

            function setupAnalyser(mediaEl) {
                if (connectedElements.has(mediaEl)) return;
                try {
                    if (!audioCtx) {
                        audioCtx = new (window.AudioContext || window.webkitAudioContext)();
                        analyser = audioCtx.createAnalyser();
                        analyser.fftSize = 128;
                        analyser.smoothingTimeConstant = 0.8;
                        analyser.connect(audioCtx.destination);
                        dataArray = new Uint8Array(analyser.frequencyBinCount);
                    }
                    var source = audioCtx.createMediaElementSource(mediaEl);
                    source.connect(analyser);
                    connectedElements.add(mediaEl);
                } catch(e) {}
            }

            function sendLevels() {
                if (!analyser || !dataArray) return;
                analyser.getByteFrequencyData(dataArray);
                var bins = [];
                var binSize = Math.floor(dataArray.length / 32);
                for (var i = 0; i < 32; i++) {
                    var sum = 0;
                    for (var j = 0; j < binSize; j++) {
                        sum += dataArray[i * binSize + j];
                    }
                    bins.push(Math.round(sum / binSize));
                }
                try {
                    window.webkit.messageHandlers.audioLevels.postMessage(bins);
                } catch(e) {}
            }

            setInterval(function() {
                document.querySelectorAll('video, audio').forEach(setupAnalyser);
                sendLevels();
            }, 80);
        })();
        """
        webView.evaluateJavaScript(js)
    }

    func injectPlayerControls() {
        let js = """
        (function() {
            var old = document.getElementById('criterion-now-style');
            if (old) old.remove();

            var css = `
                html, body {
                    background: black !important;
                    overflow: hidden !important;
                    margin: 0 !important;
                    padding: 0 !important;
                }
                header, footer, nav,
                [role="navigation"], [role="banner"], [role="contentinfo"] {
                    display: none !important;
                }
                .site-header, .site-footer, .cookie-banner,
                [class*="cookie"], [class*="banner"],
                [class*="sidebar"], [class*="promo"],
                [class*="modal"]:not([class*="player"]),
                [class*="overlay"]:not([class*="player"]) {
                    display: none !important;
                }
            `;

            var style = document.createElement('style');
            style.id = 'criterion-now-style';
            style.textContent = css;
            document.head.appendChild(style);

            var video = document.querySelector('video');
            var iframe = document.querySelector('iframe[src*="vimeo"], iframe[src*="player"], iframe[src*="stream"], iframe[src*="video"]');

            var target = video || iframe;
            if (target) {
                target.style.cssText = 'position:fixed!important;top:0!important;left:0!important;width:100vw!important;height:100vh!important;object-fit:contain!important;z-index:999999!important;border:none!important;';

                var el = target.parentElement;
                while (el && el !== document.documentElement) {
                    el.style.setProperty('display', 'block', 'important');
                    el.style.setProperty('visibility', 'visible', 'important');
                    el.style.setProperty('opacity', '1', 'important');
                    el.style.setProperty('position', 'static', 'important');
                    el.style.setProperty('overflow', 'visible', 'important');
                    el.style.setProperty('width', '100%', 'important');
                    el.style.setProperty('height', '100%', 'important');
                    el.style.setProperty('max-width', 'none', 'important');
                    el.style.setProperty('max-height', 'none', 'important');
                    el.style.setProperty('padding', '0', 'important');
                    el.style.setProperty('margin', '0', 'important');
                    el = el.parentElement;
                }

                if (video) {
                    video.volume = \(volume);
                    video.play().catch(function(){});
                }
            }

            document.querySelectorAll('audio').forEach(function(el) {
                el.volume = \(volume);
            });

            // Hide siblings of player path
            if (target) {
                var node = target;
                while (node.parentElement && node.parentElement !== document.documentElement) {
                    var parent = node.parentElement;
                    Array.from(parent.children).forEach(function(sibling) {
                        if (sibling !== node && !sibling.contains(target) &&
                            sibling.tagName !== 'STYLE' && sibling.tagName !== 'SCRIPT' &&
                            sibling.tagName !== 'LINK') {
                            sibling.style.setProperty('display', 'none', 'important');
                        }
                    });
                    node = parent;
                }
            }
        })();
        """
        webView.evaluateJavaScript(js)
    }
}

// MARK: - Audio Level Message Handler

class AudioMessageHandler: NSObject, WKScriptMessageHandler {
    var onLevels: (([Float]) -> Void)?

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "audioLevels",
              let bins = message.body as? [Int] else { return }
        let floats = bins.map { Float($0) / 255.0 }
        onLevels?(floats)
    }
}

// MARK: - Navigation Delegate

class PlayerNavigationDelegate: NSObject, WKNavigationDelegate {
    var onPageLoad: (() -> Void)?

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        onPageLoad?()
    }
}
