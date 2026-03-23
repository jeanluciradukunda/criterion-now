import SwiftUI
import WebKit

struct StreamWebView: NSViewRepresentable {
    let webView: WKWebView

    func makeNSView(context: Context) -> WKWebView {
        // Don't disable background — it kills video rendering
        return webView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {}
}
