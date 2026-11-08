import WebKit
import XCTest
@testable import Criterion_Now

@MainActor
final class CriterionLibraryExtractionTests: XCTestCase {
    private var webView: WKWebView!
    private var loadDelegate: LoadDelegate!

    override func setUp() async throws {
        let url = try XCTUnwrap(Bundle(for: Self.self).url(forResource: "my-list", withExtension: "html"))
        let html = try String(contentsOf: url, encoding: .utf8)
        webView = WKWebView(frame: .zero)
        let loaded = expectation(description: "fixture loaded")
        loadDelegate = LoadDelegate { loaded.fulfill() }
        webView.navigationDelegate = loadDelegate
        webView.loadHTMLString(html, baseURL: URL(string: "https://www.criterionchannel.com/my-list"))
        await fulfillment(of: [loaded], timeout: 10)
    }

    private func extract() async throws -> [LibraryMovie] {
        let result = try await webView.evaluateJavaScript(CriterionLibraryService.extractionJS)
        return CriterionLibraryService.parseMovies(from: try XCTUnwrap(result as? [[String: Any]]))
    }

    func testExtractsEachCardOnceInPageOrder() async throws {
        let movies = try await extract()
        XCTAssertEqual(movies.map(\.slug), [
            "snake-eyes", "kiss-of-the-spider-woman", "starring-gene-tierney",
            "conbody-vs-everybody", "november-monthly-teaser",
        ])
    }

    func testCountMatchesExtraction() async throws {
        let count = try await webView.evaluateJavaScript(CriterionLibraryService.countJS) as? Int
        XCTAssertEqual(count, 5)
    }

    func testMapsLinkKindToItemType() async throws {
        let types = try await extract().map(\.itemType)
        XCTAssertEqual(types, [.movie, .movie, .collection, .collection, .video])
    }

    func testReadsTitleURLAndLazyImage() async throws {
        let movies = try await extract()
        let film = try XCTUnwrap(movies.first)
        XCTAssertEqual(film.title, "Snake Eyes")
        XCTAssertEqual(film.criterionURL.absoluteString, "https://www.criterionchannel.com/films/JEnAxeoh/snake-eyes")
        XCTAssertEqual(film.imageURL?.absoluteString,
                       "https://cdn.jwplayer.com/v2/media/JEnAxeoh/images/regalia_16x9.webp?fallback=default_16x9&width=1024")
    }

    func testDecodesEntitiesInTitles() async throws {
        let movies = try await extract()
        XCTAssertEqual(movies[1].title, "Kiss of the Spider Woman & Other Stories")
    }
}

private final class LoadDelegate: NSObject, WKNavigationDelegate {
    private let onFinish: () -> Void

    init(onFinish: @escaping () -> Void) { self.onFinish = onFinish }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) { onFinish() }
}
