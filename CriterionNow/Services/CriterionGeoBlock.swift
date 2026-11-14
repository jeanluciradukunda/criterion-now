import Foundation

enum CriterionGeoBlock {
    /// Criterion redirects every page to /geo-block outside the regions it serves.
    static func isGeoBlocked(_ url: URL?) -> Bool {
        guard let url, let host = url.host?.lowercased(), host.hasSuffix("criterionchannel.com") else { return false }
        return url.path.lowercased().hasPrefix("/geo-block")
    }

    /// Signed out, /my-list redirects to the subscribe page.
    static func isSignedOut(_ url: URL?) -> Bool {
        guard let url, let host = url.host?.lowercased(), host.hasSuffix("criterionchannel.com") else { return false }
        let path = url.path.lowercased()
        return path.hasPrefix("/subscribe") || path.hasPrefix("/login")
    }

    static func check(_ url: URL?) throws {
        if isGeoBlocked(url) { throw CriterionError.geoBlocked }
    }
}
