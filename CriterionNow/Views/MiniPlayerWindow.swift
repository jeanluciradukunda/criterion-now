import SwiftUI
import AppKit
import Combine

/// Custom panel that can become key (allows button clicks) while staying floating
class KeyablePanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
}

class MiniPlayerWindowController: NSWindowController, NSWindowDelegate {
    static let shared = MiniPlayerWindowController()

    private var hostingView: NSHostingView<AnyView>?
    private var playerRef: PlayerManager?
    private let settings = SettingsManager.shared

    private init() {
        let panel = KeyablePanel(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 360),
            styleMask: [.titled, .closable, .resizable, .nonactivatingPanel, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        panel.title = "Criterion Now"
        panel.titlebarAppearsTransparent = true
        panel.titleVisibility = .hidden
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.isMovableByWindowBackground = true
        panel.backgroundColor = NSColor.black
        panel.isOpaque = true
        panel.minSize = NSSize(width: 340, height: 260)
        panel.animationBehavior = .utilityWindow
        panel.hasShadow = true
        panel.acceptsMouseMovedEvents = true

        super.init(window: panel)
        panel.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func show(player: PlayerManager, viewModel: NowPlayingViewModel) {
        playerRef = player
        let content = MiniPlayerFloatingView(player: player, viewModel: viewModel)
        let hosting = NSHostingView(rootView: AnyView(content))
        window?.contentView = hosting
        self.hostingView = hosting

        // Apply always-on-top setting
        updateAlwaysOnTop()

        // Restore saved position or center
        if let savedFrame = settings.savedMiniPlayerFrame() {
            window?.setFrame(savedFrame, display: true)
        } else {
            window?.center()
        }

        window?.makeKeyAndOrderFront(nil)
    }

    func hide() {
        savePosition()
        window?.orderOut(nil)
        window?.contentView = nil
        hostingView = nil
    }

    func updateAlwaysOnTop() {
        if let panel = window as? NSPanel {
            if settings.miniPlayerAlwaysOnTop {
                panel.level = .floating
                panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            } else {
                panel.level = .normal
                panel.collectionBehavior = [.fullScreenAuxiliary]
            }
        }
    }

    private func savePosition() {
        guard let frame = window?.frame, settings.miniPlayerRememberPosition else { return }
        settings.saveMiniPlayerFrame(frame)
    }

    // MARK: - NSWindowDelegate

    func windowWillClose(_ notification: Notification) {
        savePosition()
        playerRef?.stopStreaming()
        playerRef?.dock = .docked
        window?.contentView = nil
        hostingView = nil
    }

    func windowDidMove(_ notification: Notification) {
        savePosition()
    }

    func windowDidResize(_ notification: Notification) {
        savePosition()
    }
}

// MARK: - Floating Mini Player View

struct MiniPlayerFloatingView: View {
    @ObservedObject var player: PlayerManager
    @ObservedObject var viewModel: NowPlayingViewModel
    @State private var isHovering = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if player.mode == .radio {
                radioContentView
            } else {
                videoContentView
            }

            // Controls overlay — always present, fades on hover
            VStack {
                Spacer()
                controlsOverlay
            }
        }
        .frame(minWidth: 340, minHeight: 260)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovering = hovering
            }
        }
    }

    // MARK: - Video Content

    private var videoContentView: some View {
        ZStack {
            StreamWebView(webView: player.webView)

            if player.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
            }
        }
    }

    // MARK: - Radio Content

    private var radioContentView: some View {
        GeometryReader { geo in
            ZStack {
                // Blurred poster background
                if let posterImage = viewModel.posterImage {
                    Image(nsImage: posterImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geo.size.width, height: geo.size.height)
                        .blur(radius: 40)
                        .scaleEffect(1.3)
                        .clipped()
                        .overlay(Color.black.opacity(0.35))
                }

                VStack(spacing: 0) {
                    Spacer(minLength: 12)

                    // Full poster with rounded edges
                    if let posterImage = viewModel.posterImage {
                        Image(nsImage: posterImage)
                            .resizable()
                            .aspectRatio(2/3, contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(color: .black.opacity(0.7), radius: 20, y: 8)
                            .padding(.horizontal, 30)
                    }

                    Spacer(minLength: 10)

                    // Audio-reactive visualizer
                    AudioVisualizerView(
                        barCount: 48,
                        color: AppAccent.current,
                        isPlaying: player.mode == .radio,
                        audioLevels: player.audioLevels
                    )
                    .frame(height: 40)
                    .padding(.horizontal, 24)

                    // Radio badge
                    HStack(spacing: 5) {
                        Circle()
                            .fill(.red)
                            .frame(width: 6, height: 6)
                        Text("RADIO MODE")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                    }
                    .foregroundStyle(.white.opacity(0.9))
                    .padding(.top, 6)
                    .padding(.bottom, 58) // Room for controls
                }
            }
        }
    }

    // MARK: - Controls Overlay

    private var controlsOverlay: some View {
        VStack(spacing: 0) {
            // Gradient fade into controls
            LinearGradient(
                colors: [.clear, .black.opacity(0.75)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 30)

            // Controls bar
            VStack(spacing: 5) {
                // Title row
                if let movie = viewModel.movie {
                    HStack {
                        VStack(alignment: .leading, spacing: 1) {
                            Text(movie.displayTitle)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.white)
                                .lineLimit(1)
                            if !movie.director.isEmpty {
                                Text("Dir. \(movie.director)")
                                    .font(.system(size: 10))
                                    .foregroundStyle(.white.opacity(0.5))
                            }
                        }
                        Spacer()
                        if !movie.nextFilmIn.isEmpty {
                            Text("Next in \(movie.nextFilmIn)")
                                .font(.system(size: 9, weight: .medium, design: .monospaced))
                                .foregroundStyle(.white.opacity(0.4))
                        }
                    }
                }

                // Volume + buttons
                HStack(spacing: 8) {
                    Image(systemName: volumeIcon)
                        .font(.system(size: 10))
                        .foregroundStyle(.white.opacity(0.7))
                        .frame(width: 14)
                        .onTapGesture {
                            player.volume = player.volume > 0 ? 0 : 0.8
                        }

                    PanelSlider(value: $player.volume)
                        .frame(maxWidth: 90, maxHeight: 14)

                    Spacer()

                    // Subtitles toggle
                    MiniControlButton(
                        icon: player.subtitlesEnabled ? "captions.bubble.fill" : "captions.bubble",
                        isActive: player.subtitlesEnabled
                    ) {
                        player.toggleSubtitles()
                    }

                    MiniControlButton(
                        icon: player.mode == .radio ? "radio.fill" : "radio",
                        isActive: player.mode == .radio
                    ) {
                        player.toggleRadioMode()
                    }

                    MiniControlButton(
                        icon: "arrow.down.right.and.arrow.up.left",
                        isActive: false
                    ) {
                        player.toggleDock()
                    }

                    MiniControlButton(
                        icon: "stop.fill",
                        isActive: false,
                        tint: .red
                    ) {
                        player.stopStreaming()
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 10)
            .padding(.top, 4)
            .background(.black.opacity(0.75))
        }
        .opacity(isHovering ? 1 : 0.3)
    }

    private var volumeIcon: String {
        if player.volume == 0 { return "speaker.slash.fill" }
        if player.volume < 0.33 { return "speaker.fill" }
        if player.volume < 0.66 { return "speaker.wave.1.fill" }
        return "speaker.wave.2.fill"
    }
}

// MARK: - Mini Player Control Button

struct MiniControlButton: View {
    let icon: String
    var isActive: Bool = false
    var tint: Color = AppAccent.current
    let action: () -> Void

    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(isActive ? tint : (isHovering ? .white : .white.opacity(0.6)))
                .frame(width: 26, height: 22)
                .background {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(isHovering ? Color.white.opacity(0.15) : Color.clear)
                }
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.1)) {
                isHovering = hovering
            }
        }
    }
}

// MARK: - AppKit-backed Slider for NSPanel

/// NSSlider wrapper that works reliably in NSPanel/KeyablePanel windows
/// where SwiftUI gesture recognizers fail to receive mouse events.
struct PanelSlider: NSViewRepresentable {
    @Binding var value: Double

    func makeNSView(context: Context) -> NSSlider {
        let slider = NSSlider(value: value, minValue: 0, maxValue: 1, target: context.coordinator, action: #selector(Coordinator.sliderChanged(_:)))
        slider.isContinuous = true
        slider.controlSize = .mini
        // Style it to blend with dark UI
        slider.cell?.controlTint = .graphiteControlTint
        return slider
    }

    func updateNSView(_ nsView: NSSlider, context: Context) {
        if !context.coordinator.isDragging {
            nsView.doubleValue = value
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(value: $value)
    }

    class Coordinator: NSObject {
        var value: Binding<Double>
        var isDragging = false

        init(value: Binding<Double>) {
            self.value = value
        }

        @objc func sliderChanged(_ sender: NSSlider) {
            isDragging = true
            value.wrappedValue = sender.doubleValue
            // Reset drag flag after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.isDragging = false
            }
        }
    }
}
