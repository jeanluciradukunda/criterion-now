import SwiftUI
import UserNotifications

enum SettingsTab: String, CaseIterable {
    case general = "General"
    case integrations = "Integrations"
    case developer = "Developer"

    var icon: String {
        switch self {
        case .general: return "gearshape"
        case .integrations: return "link"
        case .developer: return "hammer"
        }
    }
}

struct SettingsView: View {
    @ObservedObject var settings: SettingsManager
    @State private var selectedTab: SettingsTab = .general

    var body: some View {
        VStack(spacing: 0) {
            // Tab bar
            HStack(spacing: 0) {
                ForEach(visibleTabs, id: \.self) { tab in
                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) { selectedTab = tab }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: tab.icon)
                                .font(.system(size: 9))
                            Text(tab.rawValue)
                                .font(.system(size: 10, weight: selectedTab == tab ? .bold : .medium))
                        }
                        .foregroundStyle(selectedTab == tab ? .white : .secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 7)
                        .background {
                            if selectedTab == tab {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(AppAccent.current.opacity(0.6))
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(3)
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.quaternary.opacity(0.2))
            }
            .padding(.horizontal, 18)
            .padding(.top, 12)

            // Tab content
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 16) {
                    switch selectedTab {
                    case .general:
                        generalContent
                    case .integrations:
                        integrationsContent
                    case .developer:
                        developerContent
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 12)
                .padding(.bottom, 16)
            }
        }
        .frame(width: 360, height: 560)
        .background(.regularMaterial)
    }

    private var visibleTabs: [SettingsTab] {
        if settings.developerMode {
            return SettingsTab.allCases
        }
        return [.general, .integrations]
    }

    // MARK: - General Tab

    private var generalContent: some View {
        Group {
            settingsHeader

            GlassSection(title: "Menu Bar", icon: "menubar.rectangle") {
                GlassToggle(title: "Show film title", subtitle: "Display current film next to icon", isOn: $settings.showTitleInMenuBar)
            }

            GlassSection(title: "Notifications", icon: "bell") {
                GlassToggle(title: "New film alerts", subtitle: "Notify when a new film starts on Criterion 24/7", isOn: $settings.notifyNewFilm)
                SectionDivider()
                Button {
                    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        NotificationCenter.default.post(name: .sendTestNotification, object: nil)
                    }
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "bell.badge").font(.system(size: 10))
                        Text("Send Test Notification").font(.system(size: 11, weight: .medium))
                    }
                    .foregroundStyle(AppAccent.current)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background { RoundedRectangle(cornerRadius: 8).fill(AppAccent.current.opacity(0.1)) }
                }
                .buttonStyle(.plain)
            }

            GlassSection(title: "Mini Player", icon: "pip") {
                GlassToggle(title: "Always on top", subtitle: "Float above all other windows", isOn: $settings.miniPlayerAlwaysOnTop)
                SectionDivider()
                GlassToggle(title: "Remember position", subtitle: "Restore window placement between sessions", isOn: $settings.miniPlayerRememberPosition)
            }

            GlassSection(title: "Library", icon: "books.vertical") {
                GlassToggle(title: "Inline flip cards", subtitle: "Browse library in the menu popover", isOn: $settings.libraryInlineMode)
                SectionDivider()
                GlassToggle(title: "Inline globe", subtitle: "Show cinema world globe in the menu popover", isOn: $settings.statisticsInlineMode)
            }

            GlassSection(title: "Playback", icon: "play.circle") {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Default volume").font(.system(size: 12, weight: .medium))
                        Spacer()
                        Text("\(Int(settings.defaultVolume * 100))%")
                            .font(.system(size: 11, weight: .semibold, design: .monospaced))
                            .foregroundStyle(AppAccent.current)
                    }
                    HStack(spacing: 8) {
                        Image(systemName: "speaker.fill").font(.system(size: 9)).foregroundStyle(.tertiary)
                        Slider(value: $settings.defaultVolume, in: 0...1).tint(AppAccent.current).controlSize(.small)
                        Image(systemName: "speaker.wave.3.fill").font(.system(size: 9)).foregroundStyle(.tertiary)
                    }
                }
                SectionDivider()
                GlassToggle(title: "Enable scrobbling", subtitle: "Scrobble soundtrack tracks to Last.fm", isOn: $settings.scrobblingEnabled)
            }

            GlassSection(title: "System", icon: "gear") {
                GlassToggle(title: "Launch at login", subtitle: "Start Criterion Now when you log in", isOn: $settings.launchAtLogin)
                SectionDivider()
                GlassToggle(title: "Developer mode", subtitle: "Show advanced settings and scoring controls", isOn: $settings.developerMode)
            }

            settingsFooter
        }
    }

    // MARK: - Integrations Tab

    private var integrationsContent: some View {
        Group {
            GlassSection(title: "Last.fm", icon: "music.note") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Status").font(.system(size: 12, weight: .medium))
                        Spacer()
                        if lastFMUsername != nil {
                            HStack(spacing: 4) {
                                Circle().fill(.green).frame(width: 6, height: 6)
                                Text(lastFMUsername!).font(.system(size: 10, weight: .semibold)).foregroundStyle(.green)
                            }
                        } else {
                            Text("Not connected").font(.system(size: 10)).foregroundStyle(.tertiary)
                        }
                    }

                    if lastFMUsername != nil {
                        glassButton(label: "Disconnect", color: .red) {
                            Task {
                                let service = LastFMService()
                                await service.logout()
                                settings.objectWillChange.send()
                            }
                        }
                    } else {
                        glassButton(label: "Connect to Last.fm", color: .orange) {
                            Task {
                                let service = LastFMService()
                                try? await service.authenticate()
                                settings.objectWillChange.send()
                            }
                        }
                    }
                }
            }

            GlassSection(title: "Data", icon: "cylinder.split.1x2") {
                GlassToggle(title: "Enable caching", subtitle: "Cache data until the current film ends", isOn: $settings.enableCaching)
                SectionDivider()
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Auto-refresh").font(.system(size: 12, weight: .medium))
                        Spacer()
                        Text(settings.autoRefreshMinutes == 0 ? "Off" : "\(Int(settings.autoRefreshMinutes))m")
                            .font(.system(size: 11, weight: .semibold, design: .monospaced)).foregroundStyle(AppAccent.current)
                    }
                    Slider(value: $settings.autoRefreshMinutes, in: 0...30, step: 1).tint(AppAccent.current).controlSize(.small)
                }
            }

            settingsFooter
        }
    }

    // MARK: - Developer Tab

    private var developerContent: some View {
        Group {
            GlassSection(title: "Accent Color", icon: "paintpalette") {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 50), spacing: 8)], spacing: 8) {
                    ForEach(AppAccent.options) { option in
                        Button {
                            settings.accentColorName = option.id
                        } label: {
                            VStack(spacing: 4) {
                                Circle()
                                    .fill(option.color)
                                    .frame(width: 24, height: 24)
                                    .overlay {
                                        if settings.accentColorName == option.id {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 10, weight: .bold))
                                                .foregroundStyle(.white)
                                        }
                                    }
                                    .shadow(color: settings.accentColorName == option.id ? option.color.opacity(0.5) : .clear, radius: 4)
                                Text(option.name)
                                    .font(.system(size: 7, weight: settings.accentColorName == option.id ? .bold : .regular))
                                    .foregroundStyle(settings.accentColorName == option.id ? .primary : .tertiary)
                                    .lineLimit(1)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            GlassSection(title: "API Keys", icon: "key") {
                apiKeyRow(.tmdbApiKey)
                SectionDivider()
                apiKeyRow(.lastfmApiKey)
                SectionDivider()
                apiKeyRow(.lastfmSharedSecret)
                SectionDivider()
                apiKeyRow(.discogsToken)
            }

            GlassSection(title: "Scoring Weights", icon: "slider.horizontal.3") {
                // Radar diagram
                RadarChartView(
                    axes: [
                        ("Title", settings.scoreWeightTitle, 40),
                        ("Keywords", settings.scoreWeightKeywords, 30),
                        ("Composer", settings.scoreWeightComposer, 35),
                        ("Year", settings.scoreWeightYear, 15),
                        ("Source", settings.scoreWeightSource, 20),
                        ("Content", settings.scoreWeightContent, 10),
                    ],
                    threshold: settings.scoreMinThreshold,
                    maxTotal: 150
                )
                .frame(height: 180)
                .padding(.bottom, 4)

                SectionDivider()

                scoreSlider(label: "Title match", value: $settings.scoreWeightTitle, max: 40)
                SectionDivider()
                scoreSlider(label: "Soundtrack keywords", value: $settings.scoreWeightKeywords, max: 30)
                SectionDivider()
                scoreSlider(label: "Composer match", value: $settings.scoreWeightComposer, max: 35)
                SectionDivider()
                scoreSlider(label: "Year proximity", value: $settings.scoreWeightYear, max: 15)
                SectionDivider()
                scoreSlider(label: "Source trust", value: $settings.scoreWeightSource, max: 20)
                SectionDivider()
                scoreSlider(label: "Content completeness", value: $settings.scoreWeightContent, max: 10)
                SectionDivider()
                scoreSlider(label: "Min threshold", value: $settings.scoreMinThreshold, max: 80)

                SectionDivider()

                glassButton(label: "Reset to Defaults", color: .orange) {
                    settings.scoreWeightTitle = 30
                    settings.scoreWeightKeywords = 20
                    settings.scoreWeightComposer = 25
                    settings.scoreWeightYear = 10
                    settings.scoreWeightSource = 15
                    settings.scoreWeightContent = 5
                    settings.scoreMinThreshold = 40
                }
            }

            GlassSection(title: "Source Trust Scores", icon: "chart.bar") {
                VStack(alignment: .leading, spacing: 6) {
                    trustRow(name: "Wikidata", score: 15, color: .blue)
                    trustRow(name: "MusicBrainz", score: 12, color: .purple)
                    trustRow(name: "Discogs", score: 11, color: .orange)
                    trustRow(name: "iTunes", score: 8, color: .pink)
                    trustRow(name: "Last.fm", score: 5, color: .red)
                }
                .font(.system(size: 10))
            }

            metricsSection

            settingsFooter
        }
    }

    // MARK: - Metrics Section

    @StateObject private var metrics = MetricsService.shared

    private var metricsSection: some View {
        GlassSection(title: "App Metrics", icon: "gauge.with.dots.needle.33percent") {
            // Gauges row
            HStack(spacing: 10) {
                metricGauge(label: "Real Mem", value: metrics.realMemoryMB, unit: "MB", max: 200, color: .blue)
                    .help("Physical memory used by this process, including shared frameworks. Matches Activity Monitor's 'Memory' column.")
                metricGauge(label: "Private", value: metrics.privateMemoryMB, unit: "MB", max: 100, color: .cyan)
                    .help("Memory exclusive to this process — not shared with other apps. This is the actual cost of Criterion Now on your system.")
                metricGauge(label: "CPU", value: metrics.cpuUsagePercent, unit: "%", max: 100, color: .orange)
                    .help("Total CPU usage across all threads. 100% = one full core.")
                metricGauge(label: "Threads", value: Double(metrics.threadCount), unit: "", max: 40, color: .green)
                    .help("Active threads. Each concurrent task, timer, and WebKit process uses a thread.")
            }
            .frame(maxWidth: .infinity)

            SectionDivider()

            // Memory sparkline
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Real Memory").font(.system(size: 9, weight: .medium)).foregroundStyle(.secondary)
                    Spacer()
                    Text(String(format: "%.1f MB", metrics.realMemoryMB))
                        .font(.system(size: 8, weight: .semibold, design: .monospaced)).foregroundStyle(.blue)
                }
                SparklineView(data: metrics.memoryHistory, color: .blue, height: 28)
            }

            SectionDivider()

            // CPU sparkline
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("CPU").font(.system(size: 9, weight: .medium)).foregroundStyle(.secondary)
                    Spacer()
                    Text(String(format: "%.1f%%", metrics.cpuUsagePercent))
                        .font(.system(size: 8, weight: .semibold, design: .monospaced)).foregroundStyle(AppAccent.current)
                }
                SparklineView(data: metrics.cpuHistory, color: .orange, height: 28)
            }

            SectionDivider()

            // Memory breakdown
            VStack(spacing: 4) {
                metricRow("Virtual Memory", String(format: "%.2f GB", metrics.virtualMemoryGB), .purple,
                          tip: "Total address space reserved by the process. Mostly unused — macOS allocates virtual memory generously. This number is always large.")
                metricRow("Shared Memory", String(format: "%.1f MB", metrics.sharedMemoryMB), .teal,
                          tip: "Memory shared with other processes (system frameworks, fonts, GPU resources). Not exclusive to this app.")
                metricRow("Heap", String(format: "%.1f MB", metrics.heapAllocMB), .indigo,
                          tip: "Dynamically allocated memory from malloc. Includes all Swift objects, arrays, strings, and cached data.")
            }

            SectionDivider()

            // System stats
            VStack(spacing: 4) {
                metricRow("CPU Time", metrics.cpuTimeFormatted, .orange,
                          tip: "Total CPU time consumed since launch (user + system). Lower is better for a background app.")
                metricRow("Threads", "\(metrics.threadCount)", .green,
                          tip: "Active threads including GCD workers, WebKit, timers, and async tasks.")
                metricRow("Ports", "\(metrics.portCount)", .mint,
                          tip: "Mach ports — IPC channels to system services. WebKit and notifications use many ports.")
            }

            SectionDivider()

            // Kernel stats
            VStack(spacing: 4) {
                metricRow("Context Switches", formatLargeNumber(metrics.contextSwitches), .yellow,
                          tip: "Times the CPU switched between threads. High numbers indicate heavy multithreading.")
                metricRow("Page Faults", formatLargeNumber(metrics.pageFaults), .red,
                          tip: "Memory pages accessed that weren't in RAM. Spikes mean the app is touching cold memory.")
                metricRow("Page Ins", formatLargeNumber(metrics.pageIns), .red,
                          tip: "Pages read from disk into RAM. High values indicate memory pressure — the system is swapping.")
                metricRow("Mach Syscalls", formatLargeNumber(metrics.machSysCalls), .gray,
                          tip: "Calls to the Mach kernel (IPC, memory management). Baseline overhead of running on macOS.")
                metricRow("Unix Syscalls", formatLargeNumber(metrics.unixSysCalls), .gray,
                          tip: "POSIX system calls (file I/O, networking, signals). Network requests drive this number up.")
            }

            SectionDivider()

            // Uptime
            metricRow("Uptime", metrics.uptimeFormatted, .secondary, tip: "Time since Criterion Now was launched.")
        }
        .onAppear { metrics.startMonitoring() }
        .onDisappear { metrics.stopMonitoring() }
    }

    private func metricRow(_ label: String, _ value: String, _ color: Color, tip: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(.secondary)
                .help(tip)
            Spacer()
            Text(value)
                .font(.system(size: 9, weight: .semibold, design: .monospaced))
                .foregroundStyle(color)
        }
    }

    private func formatLargeNumber(_ n: Int64) -> String {
        if n >= 1_000_000 { return String(format: "%.1fM", Double(n) / 1_000_000) }
        if n >= 1_000 { return String(format: "%.1fK", Double(n) / 1_000) }
        return "\(n)"
    }

    private func metricGauge(label: String, value: Double, unit: String, max: Double, color: Color) -> some View {
        VStack(spacing: 3) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.15), lineWidth: 3)
                    .frame(width: 40, height: 40)

                Circle()
                    .trim(from: 0, to: min(value / max, 1.0))
                    .stroke(color, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: 40, height: 40)
                    .rotationEffect(.degrees(-90))

                Text(String(format: "%.0f", value))
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundStyle(color)
            }
            Text(label)
                .font(.system(size: 7))
                .foregroundStyle(.tertiary)
        }
    }

    // MARK: - Helpers

    private func apiKeyRow(_ key: KeychainService.Key) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(key.displayName).font(.system(size: 11, weight: .medium))
            HStack {
                let current = KeychainService.get(key) ?? ""
                let masked = current.isEmpty ? "Not set" : "••••" + current.suffix(6)
                Text(masked)
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundStyle(.tertiary)
                Spacer()
                Button("Edit") {
                    // Copy current to pasteboard for editing
                    if let val = KeychainService.get(key) {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(val, forType: .string)
                    }
                }
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(AppAccent.current)
                .buttonStyle(.plain)

                Button("Paste") {
                    if let val = NSPasteboard.general.string(forType: .string), !val.isEmpty {
                        KeychainService.set(key, value: val)
                        settings.objectWillChange.send()
                    }
                }
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(.blue)
                .buttonStyle(.plain)
            }
        }
    }

    private func scoreSlider(label: String, value: Binding<Double>, max: Double) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label).font(.system(size: 11, weight: .medium))
                Spacer()
                Text("\(Int(value.wrappedValue))")
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .foregroundStyle(AppAccent.current)
            }
            Slider(value: value, in: 0...max, step: 1).tint(AppAccent.current).controlSize(.small)
        }
    }

    private func trustRow(name: String, score: Int, color: Color) -> some View {
        HStack(spacing: 8) {
            Circle().fill(color).frame(width: 6, height: 6)
            Text(name).frame(width: 80, alignment: .leading)
            GeometryReader { geo in
                RoundedRectangle(cornerRadius: 2)
                    .fill(color.opacity(0.6))
                    .frame(width: geo.size.width * (Double(score) / 15.0))
            }
            .frame(height: 6)
            Text("\(score)").foregroundStyle(.tertiary).frame(width: 20, alignment: .trailing)
        }
    }

    private func glassButton(label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(color)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(color.opacity(0.1))
                        .overlay { RoundedRectangle(cornerRadius: 8).strokeBorder(color.opacity(0.2), lineWidth: 0.5) }
                }
        }
        .buttonStyle(.plain)
    }

    private var lastFMUsername: String? {
        UserDefaults.standard.string(forKey: "lastfm_username")
    }

    // MARK: - Header & Footer

    private var settingsHeader: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle().fill(.quaternary.opacity(0.3)).frame(width: 42, height: 42)
                Image("MenuBarIcon").resizable().renderingMode(.template).frame(width: 20, height: 20).foregroundStyle(.primary)
            }
            Text("Criterion Now").font(.system(size: 14, weight: .bold))
        }
    }

    private var settingsFooter: some View {
        HStack(spacing: 3) {
            Text("Powered by").font(.system(size: 8)).foregroundStyle(.quaternary)
            Text("TMDB · MusicBrainz · Discogs · Last.fm").font(.system(size: 8, weight: .medium)).foregroundStyle(.quaternary)
        }
    }
}

// MARK: - Reusable Components

struct GlassSection<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 5) {
                Image(systemName: icon).font(.system(size: 10, weight: .semibold)).foregroundStyle(AppAccent.current)
                Text(title.uppercased()).font(.system(size: 9, weight: .bold)).tracking(1.2).foregroundStyle(.secondary)
            }
            .padding(.leading, 4)

            VStack(alignment: .leading, spacing: 10) { content }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background {
                    RoundedRectangle(cornerRadius: 12).fill(.thinMaterial)
                        .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
                        .overlay {
                            RoundedRectangle(cornerRadius: 12).strokeBorder(
                                LinearGradient(colors: [.white.opacity(0.15), .white.opacity(0.03)], startPoint: .topLeading, endPoint: .bottomTrailing),
                                lineWidth: 0.5
                            )
                        }
                }
        }
    }
}

struct SectionDivider: View {
    var body: some View {
        Rectangle().fill(.quaternary.opacity(0.3)).frame(height: 0.5).padding(.horizontal, -2)
    }
}

struct GlassToggle: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 12, weight: .medium))
                Text(subtitle).font(.system(size: 9)).foregroundStyle(.tertiary).lineLimit(2)
            }
            Spacer(minLength: 8)
            Toggle("", isOn: $isOn)
                .toggleStyle(.switch)
                .tint(AppAccent.current)
                .controlSize(.small)
                .labelsHidden()
        }
    }
}
