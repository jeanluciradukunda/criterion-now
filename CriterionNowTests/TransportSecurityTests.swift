import XCTest
@testable import Criterion_Now

final class TransportSecurityTests: XCTestCase {
    func testTheAppKeepsDefaultTransportSecurity() {
        XCTAssertNil(Bundle.main.object(forInfoDictionaryKey: "NSAppTransportSecurity"))
    }
}
