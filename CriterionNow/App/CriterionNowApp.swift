import SwiftUI
import Combine

@main
struct CriterionNowApp: App {
    @StateObject private var viewModel = NowPlayingViewModel()
    @StateObject private var player = PlayerManager()
    @StateObject private var settings = SettingsManager.shared

    init() {
        // Bootstrap API keys into Keychain on first launch
        KeychainService.bootstrapDefaults()
    }

    var body: some Scene {
        MenuBarExtra {
            NowPlayingView(viewModel: viewModel, player: player, settings: settings)
                .frame(width: 300, height: 620)
                .environment(\.appAccent, AppAccent.color(for: settings.accentColorName))
                .tint(AppAccent.color(for: settings.accentColorName))
                .onReceive(player.$dock) { newDock in
                    handleDockChange(newDock)
                }
        } label: {
            MenuBarLabel(player: player, viewModel: viewModel, settings: settings)
        }
        .menuBarExtraStyle(.window)
    }

    private func handleDockChange(_ dock: PlayerDock) {
        if dock == .undocked && player.mode != .off {
            MiniPlayerWindowController.shared.show(player: player, viewModel: viewModel)
        } else {
            MiniPlayerWindowController.shared.hide()
        }
    }
}

// Separate view so MenuBarExtra label properly observes changes
struct MenuBarLabel: View {
    @ObservedObject var player: PlayerManager
    @ObservedObject var viewModel: NowPlayingViewModel
    @ObservedObject var settings: SettingsManager

    var body: some View {
        HStack(spacing: 4) {
            Image("MenuBarIcon")
                .renderingMode(.template)
            if player.mode != .off {
                Circle()
                    .fill(player.mode == .radio ? .red : .green)
                    .frame(width: 6, height: 6)
            }
            if settings.showTitleInMenuBar, player.mode != .off, let movie = viewModel.movie {
                Text(movie.title)
            }
        }
    }
}
