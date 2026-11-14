import XCTest
@testable import Criterion_Now

final class SoundtrackLinkTests: XCTestCase {
    func testKeepsHttpsLinksOnTheServiceHosts() {
        XCTAssertNotNil(SoundtrackService.linkURL("https://music.apple.com/us/album/x/123", allowedHosts: SoundtrackService.appleMusicHosts))
        XCTAssertNotNil(SoundtrackService.linkURL("https://www.last.fm/music/A/B", allowedHosts: SoundtrackService.lastfmHosts))
    }

    func testDropsOtherSchemesAndHosts() {
        let hosts = SoundtrackService.appleMusicHosts
        XCTAssertNil(SoundtrackService.linkURL("file:///System/Applications/Calculator.app", allowedHosts: hosts))
        XCTAssertNil(SoundtrackService.linkURL("x-test-scheme://probe", allowedHosts: hosts))
        XCTAssertNil(SoundtrackService.linkURL("http://music.apple.com/us/album/x/123", allowedHosts: hosts))
        XCTAssertNil(SoundtrackService.linkURL("https://music.apple.com.example.org/album", allowedHosts: hosts))
        XCTAssertNil(SoundtrackService.linkURL(nil, allowedHosts: hosts))
    }
}
