import XCTest
@testable import Criterion_Now

final class CriterionGeoBlockTests: XCTestCase {
    func testGeoBlockRedirectIsDetected() {
        XCTAssertTrue(CriterionGeoBlock.isGeoBlocked(URL(string: "https://www.criterionchannel.com/geo-block")))
        XCTAssertTrue(CriterionGeoBlock.isGeoBlocked(URL(string: "https://www.criterionchannel.com/geo-block?from=my-list")))
    }

    func testOrdinaryPagesAreNotGeoBlocked() {
        XCTAssertFalse(CriterionGeoBlock.isGeoBlocked(URL(string: "https://www.criterionchannel.com/my-list")))
        XCTAssertFalse(CriterionGeoBlock.isGeoBlocked(URL(string: "https://www.criterionchannel.com/live/1emmgvqX/criterion-24-7")))
        XCTAssertFalse(CriterionGeoBlock.isGeoBlocked(URL(string: "https://example.com/geo-block")))
        XCTAssertFalse(CriterionGeoBlock.isGeoBlocked(nil))
    }

    func testSubscribeRedirectMeansSignedOut() {
        XCTAssertTrue(CriterionGeoBlock.isSignedOut(URL(string: "https://ca.criterionchannel.com/subscribe")))
        XCTAssertFalse(CriterionGeoBlock.isSignedOut(URL(string: "https://www.criterionchannel.com/my-list")))
        XCTAssertFalse(CriterionGeoBlock.isSignedOut(URL(string: "https://example.com/subscribe")))
    }

    func testGeoBlockErrorTellsTheUserWhatToDo() {
        let message = CriterionError.geoBlocked.errorDescription ?? ""
        XCTAssertTrue(message.contains("VPN"), message)
    }
}
