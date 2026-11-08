import XCTest
@testable import Criterion_Now

@MainActor
final class CriterionNowPlayingTests: XCTestCase {
    private var html = ""

    override func setUpWithError() throws {
        let url = try XCTUnwrap(Bundle(for: Self.self).url(forResource: "live", withExtension: "html"))
        html = try String(contentsOf: url, encoding: .utf8)
    }

    private func date(_ iso: String) throws -> Date {
        try XCTUnwrap(ISO8601DateFormatter().date(from: iso))
    }

    func testReadsScheduleSplitAcrossPushes() {
        let schedule = CriterionService.schedule(fromLivePage: html)
        XCTAssertEqual(schedule?.map(\.episodeTitle), ["I See a Dark Stranger", "Blithe Spirit", "Victims of Sin"])
    }

    func testPicksTheFilmPlayingAtTheGivenTime() throws {
        let nowPlaying = try CriterionService.nowPlaying(fromLivePage: html, at: date("2026-11-08T21:42:00Z"))
        XCTAssertEqual(nowPlaying.title, "Blithe Spirit")
        XCTAssertEqual(nowPlaying.slug, "blithe-spirit")
        XCTAssertEqual(nowPlaying.nextFilmIn, "21 minutes")
        XCTAssertEqual(NowPlayingViewModel.parseMinutes(from: nowPlaying.nextFilmIn), 21)
    }

    func testFallsBackToTitleSlugWithoutAFilmLink() throws {
        let nowPlaying = try CriterionService.nowPlaying(fromLivePage: html, at: date("2026-11-08T22:30:00Z"))
        XCTAssertEqual(nowPlaying.title, "Victims of Sin")
        XCTAssertEqual(nowPlaying.slug, "victims-of-sin")
    }

    func testReadsScheduleFromALargePush() throws {
        let entry = #"{"startTime":"2026-11-08T22:02:58Z","endTime":"2026-11-08T23:28:02Z","episodeTitle":"Victims of Sin","guid":"cOGhYMOa"}"#
        let payload = #"45:{"description":""# + String(repeating: "a \\\"quoted\\\" line. ", count: 20_000)
            + #"","schedule":["# + entry + "]}"
        let literal = try XCTUnwrap(String(data: JSONEncoder().encode(payload), encoding: .utf8))
        let page = "<script>self.__next_f.push([1,\(literal)])</script>"
        XCTAssertGreaterThan(page.utf8.count, 250_000)
        let nowPlaying = try CriterionService.nowPlaying(fromLivePage: page, at: date("2026-11-08T22:30:00Z"))
        XCTAssertEqual(nowPlaying.title, "Victims of Sin")
    }

    func testOutsideTheScheduleIsAParsingFailure() throws {
        XCTAssertThrowsError(try CriterionService.nowPlaying(fromLivePage: html, at: date("2026-12-01T00:00:00Z")))
        XCTAssertThrowsError(try CriterionService.nowPlaying(fromLivePage: "<html></html>", at: Date()))
    }
}
