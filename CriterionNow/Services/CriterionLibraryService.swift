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
            let count = (try? await wv.evaluateJavaScript(
                "document.querySelectorAll('li.js-collection-item').length"
            )) as? Int ?? 0
            if count > 0 { return }
            try await Task.sleep(nanoseconds: 400_000_000) // 0.4s poll
        }
    }

    /// Click load-more until gone or item count stops growing. No fixed cap.
    private func loadAllPages(_ wv: WKWebView, maxWait: TimeInterval = 60) async throws {
        let clickJS = """
        (function() {
            var btn = document.querySelector('.js-load-more-link, [data-load-more]');
            if (btn && btn.offsetParent !== null) { btn.click(); return true; }
            return false;
        })();
        """
        let countJS = "document.querySelectorAll('li.js-collection-item').length"

        var lastCount = (try? await wv.evaluateJavaScript(countJS)) as? Int ?? 0
        let start = Date()

        while Date().timeIntervalSince(start) < maxWait {
            let hasMore = (try? await wv.evaluateJavaScript(clickJS)) as? Bool ?? false
            if !hasMore { break }

            // Poll for new items instead of fixed sleep
            var waited: TimeInterval = 0
            while waited < 5 {
                try await Task.sleep(nanoseconds: 400_000_000)
                waited += 0.4
                let newCount = (try? await wv.evaluateJavaScript(countJS)) as? Int ?? 0
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

    private let extractionJS = """
    (function() {
        var items = document.querySelectorAll('li.js-collection-item');
        var movies = [];
        items.forEach(function(item) {
            var linkEl = item.querySelector('a.browse-item-link');
            if (!linkEl) return;
            var href = linkEl.getAttribute('href') || '';
            var titleEl = item.querySelector('.browse-item-title strong');
            if (!titleEl) titleEl = item.querySelector('.browse-item-title a');
            if (!titleEl) return;
            var title = titleEl.textContent.trim();
            var imgEl = item.querySelector('.browse-image-container img');
            var img = imgEl ? imgEl.getAttribute('src') : '';
            var itemType = item.getAttribute('data-item-type') || '';
            var slug = '';
            try {
                var url = new URL(href, 'https://www.criterionchannel.com');
                var parts = url.pathname.split('/').filter(function(p) { return p.length > 0; });
                slug = parts[parts.length - 1] || '';
            } catch(e) { slug = href.split('/').pop() || ''; }
            if (slug && title) {
                movies.push({ title: title, slug: slug, href: href, image: img, type: itemType });
            }
        });
        var seen = {};
        return movies.filter(function(m) { if (seen[m.slug]) return false; seen[m.slug] = true; return true; });
    })();
    """

    // MARK: - Fetch My List

    func fetchMyList() async throws -> [LibraryMovie] {
        let wv = getWebView()
        isScraping = true
        defer { cleanupAfterScrape() }

        wv.load(URLRequest(url: myListURL))
        try await waitForContent(wv, timeout: 15)
        try await loadAllPages(wv, maxWait: 60)

        let result = try await wv.evaluateJavaScript(extractionJS)
        return (result as? [[String: Any]]).map { parseMovies(from: $0) } ?? []
    }

    // MARK: - Fetch Collection Films

    func fetchCollectionFilms(slug: String) async throws -> (description: String, films: [LibraryMovie]) {
        let wv = getWebView()
        isScraping = true
        defer { cleanupAfterScrape() }

        wv.load(URLRequest(url: URL(string: "https://www.criterionchannel.com/\(slug)")!))
        try await waitForContent(wv, timeout: 15)
        try await loadAllPages(wv, maxWait: 30)

        let descJS = """
        (function() {
            var el = document.querySelector('.collection-description .site-font-secondary-color, meta[name="description"]');
            return el ? (el.tagName === 'META' ? el.getAttribute('content') : el.textContent.trim()) : '';
        })();
        """
        let description = (try? await wv.evaluateJavaScript(descJS)) as? String ?? ""
        let result = try await wv.evaluateJavaScript(extractionJS)
        let films = (result as? [[String: Any]]).map { parseMovies(from: $0) } ?? []
        return (description, films)
    }

    // MARK: - Parse

    /// Decode HTML entities like &amp; → &, &#39; → ', etc.
    private func decodeHTML(_ string: String) -> String {
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

    private func parseMovies(from dicts: [[String: Any]]) -> [LibraryMovie] {
        dicts.compactMap { dict -> LibraryMovie? in
            guard let rawTitle = dict["title"] as? String,
                  let slug = dict["slug"] as? String else { return nil }
            let title = decodeHTML(rawTitle)
            let href = dict["href"] as? String ?? "/\(slug)"
            let imageStr = dict["image"] as? String ?? ""
            let imageURL = imageStr.isEmpty ? nil : URL(string: imageStr
                .replacingOccurrences(of: "h=360", with: "h=720")
                .replacingOccurrences(of: "w=640", with: "w=1280"))
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
