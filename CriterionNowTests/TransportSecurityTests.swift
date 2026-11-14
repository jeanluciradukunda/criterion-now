import XCTest
@testable import Criterion_Now

final class TransportSecurityTests: XCTestCase {
    func testTheAppKeepsDefaultTransportSecurity() {
        let ats = Bundle.main.object(forInfoDictionaryKey: "NSAppTransportSecurity") as? [String: Any] ?? [:]
        XCTAssertNotEqual(ats["NSAllowsArbitraryLoads"] as? Bool, true)
        XCTAssertNotEqual(ats["NSAllowsArbitraryLoadsInWebContent"] as? Bool, true)
    }
}
