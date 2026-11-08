import Foundation

enum CriterionGeoBlock {
    /// Criterion redirects every page to /geo-block outside the regions it serves.
    static func isGeoBlocked(_ url: URL?) -> Bool {
        guard let url, let host = url.host?.lowercased(), host.hasSuffix("criterionchannel.com") else { return false }
        return url.path.lowercased().hasPrefix("/geo-block")
    }
}
