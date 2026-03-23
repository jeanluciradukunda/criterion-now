import SwiftUI
import ServiceManagement

@MainActor
class SettingsManager: ObservableObject {
    static let shared = SettingsManager()

    // MARK: - General
    @AppStorage("showTitleInMenuBar") var showTitleInMenuBar: Bool = false
    @AppStorage("notifyNewFilm") var notifyNewFilm: Bool = true
    @AppStorage("pinMenuPopover") var pinMenuPopover: Bool = false

    // MARK: - Library
    @AppStorage("libraryInlineMode") var libraryInlineMode: Bool = false

    // MARK: - Statistics
    @AppStorage("statisticsInlineMode") var statisticsInlineMode: Bool = true // true = popup, false = window

    // MARK: - Mini Player
    @AppStorage("miniPlayerAlwaysOnTop") var miniPlayerAlwaysOnTop: Bool = true
    @AppStorage("miniPlayerRememberPosition") var miniPlayerRememberPosition: Bool = true
    @AppStorage("miniPlayerX") var miniPlayerX: Double = -1
    @AppStorage("miniPlayerY") var miniPlayerY: Double = -1
    @AppStorage("miniPlayerW") var miniPlayerW: Double = 480
    @AppStorage("miniPlayerH") var miniPlayerH: Double = 360

    // MARK: - Playback
    @AppStorage("defaultVolume") var defaultVolume: Double = 0.8
    @AppStorage("defaultMode") var defaultMode: String = "video"
    @AppStorage("autoStartStream") var autoStartStream: Bool = false
    @AppStorage("scrobblingEnabled") var scrobblingEnabled: Bool = true

    // MARK: - Data & Caching
    @AppStorage("autoRefreshMinutes") var autoRefreshMinutes: Double = 0
    @AppStorage("enableCaching") var enableCaching: Bool = true

    // MARK: - Developer Mode
    @AppStorage("developerMode") var developerMode: Bool = false
    @AppStorage("accentColorName") var accentColorName: String = "orange"

    // MARK: - Scoring Weights (developer mode)
    @AppStorage("scoreWeightTitle") var scoreWeightTitle: Double = 30
    @AppStorage("scoreWeightKeywords") var scoreWeightKeywords: Double = 20
    @AppStorage("scoreWeightComposer") var scoreWeightComposer: Double = 25
    @AppStorage("scoreWeightYear") var scoreWeightYear: Double = 10
    @AppStorage("scoreWeightSource") var scoreWeightSource: Double = 15
    @AppStorage("scoreWeightContent") var scoreWeightContent: Double = 5
    @AppStorage("scoreMinThreshold") var scoreMinThreshold: Double = 40

    // MARK: - System
    @AppStorage("launchAtLogin") var launchAtLogin: Bool = false {
        didSet { updateLaunchAtLogin() }
    }

    private func updateLaunchAtLogin() {
        do {
            if launchAtLogin {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("Launch at login error: \(error)")
        }
    }

    // MARK: - Mini Player Position

    func saveMiniPlayerFrame(_ frame: NSRect) {
        miniPlayerX = Double(frame.origin.x)
        miniPlayerY = Double(frame.origin.y)
        miniPlayerW = Double(frame.size.width)
        miniPlayerH = Double(frame.size.height)
    }

    func savedMiniPlayerFrame() -> NSRect? {
        guard miniPlayerRememberPosition, miniPlayerX >= 0, miniPlayerY >= 0 else { return nil }
        return NSRect(x: miniPlayerX, y: miniPlayerY, width: miniPlayerW, height: miniPlayerH)
    }
}
