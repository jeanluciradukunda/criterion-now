import SwiftUI
import AppKit

class LibraryWindowController: NSWindowController {
    static let shared = LibraryWindowController()

    private let libraryViewModel = LibraryViewModel()
    private var hostingView: NSHostingView<AnyView>?

    private init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1000, height: 700),
            styleMask: [.titled, .closable, .resizable, .miniaturizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.title = "Criterion Now"
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.isMovableByWindowBackground = true
        window.backgroundColor = .clear
        window.isOpaque = false
        window.minSize = NSSize(width: 800, height: 550)
        window.center()

        super.init(window: window)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func show() {
        if hostingView == nil {
            let content = LibraryView(viewModel: libraryViewModel)
                .background(.regularMaterial)
            let hosting = NSHostingView(rootView: AnyView(content))
            window?.contentView = hosting
            self.hostingView = hosting
        }

        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
