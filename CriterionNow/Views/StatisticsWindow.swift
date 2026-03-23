import SwiftUI
import AppKit

class StatisticsWindowController: NSWindowController {
    static let shared = StatisticsWindowController()

    private let statsVM = StatisticsViewModel()
    private var hostingView: NSHostingView<AnyView>?

    private init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 900, height: 600),
            styleMask: [.titled, .closable, .resizable, .miniaturizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.title = "Criterion Now — Your Cinema World"
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.isMovableByWindowBackground = true
        window.backgroundColor = .black
        window.minSize = NSSize(width: 700, height: 450)
        window.center()

        super.init(window: window)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func show(movies: [LibraryMovie]) {
        let content = StatisticsWindowView(statsVM: statsVM, movies: movies)
            .background(.regularMaterial)
        let hosting = NSHostingView(rootView: AnyView(content))
        window?.contentView = hosting
        self.hostingView = hosting

        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
