import Foundation
import WebKit

@MainActor
class CriterionLibraryService {
    private var webView: WKWebView?
    private var ownsWebView = false
    private(set) var isScraping = false

    private let myListURL = URL(string: "https://www.criterionchannel.com/my-list")!

    func setSharedWebView(_ wv: WKWebView) {
        self.webView = wv
        self.ownsWebView = false
    }

    private func getWebView() -> WKWebView {
        if let wv = webView { return wv }
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .default()
        let wv = WKWebView(frame: .zero, configuration: config)
        wv.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 14_0) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Safari/605.1.15"
        self.webView = wv
        self.ownsWebView = true
        return wv
    }

    private func cleanupAfterScrape() {
        defer { isScraping = false }
        guard let wv = webView else { return }
        wv.stopLoading()
        if ownsWebView {
            webView = nil
            ownsWebView = false
            return
        }
        wv.loadHTMLString("<html><body></body></html>", baseURL: nil)
    }

    // MARK: - Readiness Polling (replaces fixed 5s sleep)

    private func waitForContent(_ wv: WKWebView, timeout: TimeInterval = 15) async throws {
        let start = Date()
        while Date().timeIntervalSince(start) < timeout {
            if CriterionGeoBlock.isGeoBlocked(wv.url) {
                throw CriterionError.geoBlocked
            }
            let count = (try? await wv.evaluateJavaScript(Self.countJS)) as? Int ?? 0
            if count > 0 { return }
            try await Task.sleep(nanoseconds: 400_000_000) // 0.4s poll
        }
        if CriterionGeoBlock.isGeoBlocked(wv.url) {
            throw CriterionError.geoBlocked
        }
    }

    /// Click load-more until gone or item count stops growing. No fixed cap.
    private func loadAllPages(_ wv: WKWebView, maxWait: TimeInterval = 60) async throws {
        let clickJS = """
        (function() {
            window.scrollTo(0, document.body.scrollHeight);
            var buttons = Array.prototype.slice.call(document.querySelectorAll('button, a[role="button"]'));
            var btn = buttons.find(function(b) {
                return /^(load|show) more$/i.test(b.textContent.trim()) && b.offsetParent !== null;
            });
            if (btn) { btn.click(); }
            return true;
        })();
        """

        var lastCount = (try? await wv.evaluateJavaScript(Self.countJS)) as? Int ?? 0
        let start = Date()

        while Date().timeIntervalSince(start) < maxWait {
            let hasMore = (try? await wv.evaluateJavaScript(clickJS)) as? Bool ?? false
            if !hasMore { break }

            // Poll for new items instead of fixed sleep
            var waited: TimeInterval = 0
            while waited < 5 {
                try await Task.sleep(nanoseconds: 400_000_000)
                waited += 0.4
                let newCount = (try? await wv.evaluateJavaScript(Self.countJS)) as? Int ?? 0
                if newCount > lastCount {
                    lastCount = newCount
                    break
                }
            }
            // If count didn't increase after 5s, assume done
            if waited >= 5 { break }
        }
    }

    // MARK: - Shared extraction JS

    /// Cards on the Next.js site: a link to /<kind>/<id>/<slug> labelled by its title element.
    /// Class names are hashed per build, so nothing here depends on them.
    private static let cardsFunctionJS = """
    function() {
        var kinds = { films: 'movie', supplements: 'video', collections: 'series', series: 'series' };
        var movies = [];
        var seen = {};
        document.querySelectorAll('a[aria-labelledby][href]').forEach(function(link) {
            var url;
            try { url = new URL(link.getAttribute('href'), 'https://www.criterionchannel.com'); } catch (e) { return; }
            var parts = url.pathname.split('/').filter(function(p) { return p.length > 0; });
            if (parts.length < 3 || !kinds[parts[0]]) return;
            var titleEl = document.getElementById(link.getAttribute('aria-labelledby').split(' ')[0]);
            var img = link.parentElement ? link.parentElement.querySelector('img') : null;
            var title = titleEl ? titleEl.textContent.trim() : (img ? (img.getAttribute('alt') || '').trim() : '');
            var slug = parts[2];
            if (!title || seen[slug]) return;
            seen[slug] = true;
            var image = img ? (img.getAttribute('data-src') || img.getAttribute('src') || '') : '';
            if (image.indexOf('data:') === 0) image = '';
            movies.push({ title: title, slug: slug, href: url.pathname, image: image, type: kinds[parts[0]] });
        });
        return movies;
    }
    """

    static let extractionJS = "(\(cardsFunctionJS))();"
    static let countJS = "(\(cardsFunctionJS))().length;"

    // MARK: - Fetch My List

    func fetchMyList() async throws -> [LibraryMovie] {
        let wv = getWebView()
        isScraping = true
        defer { cleanupAfterScrape() }

        wv.load(URLRequest(url: myListURL))
        try await waitForContent(wv, timeout: 15)
        try await loadAllPages(wv, maxWait: 60)

        let result = try await wv.evaluateJavaScript(Self.extractionJS)
        let movies = (result as? [[String: Any]]).map { Self.parseMovies(from: $0) } ?? []
        // An empty scrape must not reach the caller, which would save it over the stored library.
        if movies.isEmpty {
            throw CriterionError.emptyLibrary
        }
        return movies
    }

    // MARK: - Fetch Collection Films

    func fetchCollectionFilms(url: URL) async throws -> (description: String, films: [LibraryMovie]) {
        let wv = getWebView()
        isScraping = true
        defer { cleanupAfterScrape() }

        wv.load(URLRequest(url: url))
        try await waitForContent(wv, timeout: 15)
        try await loadAllPages(wv, maxWait: 30)

        let descJS = """
        (function() {
            var el = document.querySelector('.collection-description .site-font-secondary-color, meta[name="description"]');
            return el ? (el.tagName === 'META' ? el.getAttribute('content') : el.textContent.trim()) : '';
        })();
        """
        let description = (try? await wv.evaluateJavaScript(descJS)) as? String ?? ""
        let result = try await wv.evaluateJavaScript(Self.extractionJS)
        let films = (result as? [[String: Any]]).map { Self.parseMovies(from: $0) } ?? []
        return (description, films)
    }

    // MARK: - Parse

    /// Decode HTML entities like &amp; → &, &#39; → ', etc.
    private static func decodeHTML(_ string: String) -> String {
        string
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&#39;", with: "'")
            .replacingOccurrences(of: "&apos;", with: "'")
            .replacingOccurrences(of: "&#x27;", with: "'")
            .replacingOccurrences(of: "&#038;", with: "&")
    }

    static func parseMovies(from dicts: [[String: Any]]) -> [LibraryMovie] {
        dicts.compactMap { dict -> LibraryMovie? in
            guard let rawTitle = dict["title"] as? String,
                  let slug = dict["slug"] as? String else { return nil }
            let title = decodeHTML(rawTitle)
            let href = dict["href"] as? String ?? "/\(slug)"
            let imageStr = dict["image"] as? String ?? ""
            let imageURL = imageStr.isEmpty ? nil : URL(string: imageStr)
            let criterionURL = href.hasPrefix("http")
                ? URL(string: href)!
                : URL(string: "https://www.criterionchannel.com\(href)")!
            return LibraryMovie(
                id: slug, title: title, slug: slug,
                criterionURL: criterionURL, imageURL: imageURL,
                itemType: LibraryItemType(rawValue: dict["type"] as? String ?? "movie") ?? .movie
            )
        }
    }
}
