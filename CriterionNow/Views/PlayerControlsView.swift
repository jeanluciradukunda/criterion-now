import SwiftUI

struct PlayerControlsView: View {
    @ObservedObject var player: PlayerManager
    @ObservedObject var viewModel: NowPlayingViewModel

    var body: some View {
        VStack(spacing: 6) {
            // Volume slider
            HStack(spacing: 6) {
                Image(systemName: volumeIcon)
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
                    .frame(width: 12)
                    .onTapGesture {
                        player.volume = player.volume > 0 ? 0 : 0.8
                    }

                CustomSlider(value: $player.volume)
                    .frame(height: 4)

                Image(systemName: "speaker.wave.3.fill")
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
                    .frame(width: 12)
            }

            // Control buttons
            HStack(spacing: 10) {
                // Stop
                ControlButton(icon: "stop.fill", tooltip: "Stop") {
                    player.stopStreaming()
                }

                // Radio mode toggle
                ControlButton(
                    icon: player.mode == .radio ? "radio.fill" : "radio",
                    tooltip: player.mode == .radio ? "Switch to Video" : "Radio Mode",
                    isActive: player.mode == .radio
                ) {
                    player.toggleRadioMode()
                }

                // Dock/undock
                ControlButton(
                    icon: player.dock == .docked ? "arrow.up.left.and.arrow.down.right" : "arrow.down.right.and.arrow.up.left",
                    tooltip: player.dock == .docked ? "Undock Player" : "Dock Player",
                    isActive: player.dock == .undocked
                ) {
                    player.toggleDock()
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    private var volumeIcon: String {
        if player.volume == 0 { return "speaker.slash.fill" }
        if player.volume < 0.33 { return "speaker.fill" }
        if player.volume < 0.66 { return "speaker.wave.1.fill" }
        return "speaker.wave.2.fill"
    }
}

// MARK: - Control Button

struct ControlButton: View {
    let icon: String
    let tooltip: String
    var isActive: Bool = false
    let action: () -> Void

    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(isActive ? .orange : (isHovering ? .primary : .secondary))
                .frame(width: 28, height: 22)
                .background {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isHovering ? Color.white.opacity(0.1) : Color.clear)
                }
        }
        .buttonStyle(.plain)
        .help(tooltip)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.12)) {
                isHovering = hovering
            }
        }
    }
}

// MARK: - Custom Volume Slider

struct CustomSlider: View {
    @Binding var value: Double

    @State private var isHovering = false

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                // Track background
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.white.opacity(0.12))

                // Filled track
                RoundedRectangle(cornerRadius: 2)
                    .fill(
                        LinearGradient(
                            colors: [.orange.opacity(0.7), .red.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geo.size.width * value)

                // Thumb
                Circle()
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.3), radius: 2, y: 1)
                    .frame(width: isHovering ? 10 : 6, height: isHovering ? 10 : 6)
                    .offset(x: (geo.size.width * value) - (isHovering ? 5 : 3))
                    .animation(.easeInOut(duration: 0.1), value: isHovering)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { drag in
                        let newValue = min(max(drag.location.x / geo.size.width, 0), 1)
                        value = newValue
                    }
            )
            .onHover { hovering in
                isHovering = hovering
            }
        }
    }
}
