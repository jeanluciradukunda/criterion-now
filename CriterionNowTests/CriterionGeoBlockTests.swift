import XCTest
@testable import Criterion_Now

final class CriterionGeoBlockTests: XCTestCase {
    func testGeoBlockRedirectIsDetected() {
        XCTAssertTrue(CriterionGeoBlock.isGeoBlocked(URL(string: "https://www.criterionchannel.com/geo-block")))
        XCTAssertTrue(CriterionGeoBlock.isGeoBlocked(URL(string: "https://www.criterionchannel.com/geo-block?from=my-list")))
    }

    func testOrdinaryPagesAreNotGeoBlocked() {
        XCTAssertFalse(CriterionGeoBlock.isGeoBlocked(URL(string: "https://www.criterionchannel.com/my-list")))
        XCTAssertFalse(CriterionGeoBlock.isGeoBlocked(URL(string: "https://whatsonnow.criterionchannel.com/")))
        XCTAssertFalse(CriterionGeoBlock.isGeoBlocked(URL(string: "https://example.com/geo-block")))
        XCTAssertFalse(CriterionGeoBlock.isGeoBlocked(nil))
    }

    func testGeoBlockErrorTellsTheUserWhatToDo() {
        let message = CriterionError.geoBlocked.errorDescription ?? ""
        XCTAssertTrue(message.contains("VPN"), message)
    }
}
