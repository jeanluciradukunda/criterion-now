import Foundation

/// Persists a log of every film detected on Criterion 24/7
actor HistoryService {
    static let shared = HistoryService()

    private enum RetentionPolicy {
        static let maxEntries = 5_000
        static let maxAge: TimeInterval = 365 * 24 * 60 * 60
    }

    private var entries: [HistoryEntry] = []
    private var loaded = false

    private var historyFile: URL {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            .appendingPathComponent("CriterionNow", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("history.json")
    }

    // MARK: - Load

    func loadIfNeeded() {
        guard !loaded else { return }
        loaded = true
        guard let data = try? Data(contentsOf: historyFile) else { return }
        entries = (try? JSONDecoder().decode([HistoryEntry].self, from: data)) ?? []
        if pruneEntries() {
            save()
        }
    }

    // MARK: - Add

    func logFilm(title: String, year: String, director: String, composer: String, runtime: String, posterURL: String?) {
        loadIfNeeded()

        // Normalize for comparison — handles legacy &amp; vs & mismatches
        let normalizedTitle = title
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&#39;", with: "'")

        // Only log if the title is DIFFERENT from the most recent entry.
        if let last = entries.last {
            let lastNormalized = last.title
                .replacingOccurrences(of: "&amp;", with: "&")
                .replacingOccurrences(of: "&#39;", with: "'")
            if lastNormalized == normalizedTitle { return }
        }

        let entry = HistoryEntry(
            id: UUID().uuidString,
            title: title,
            year: year,
            director: director,
            composer: composer,
            runtime: runtime,
            posterURL: posterURL,
            timestamp: Date()
        )

        entries.append(entry)
        save()
    }

    // MARK: - Query

    func allEntries() -> [HistoryEntry] {
        loadIfNeeded()
        return entries.reversed() // Most recent first
    }

    func entriesForToday() -> [HistoryEntry] {
        loadIfNeeded()
        let calendar = Calendar.current
        return entries.filter { calendar.isDateInToday($0.timestamp) }.reversed()
    }

    func entriesForYesterday() -> [HistoryEntry] {
        loadIfNeeded()
        let calendar = Calendar.current
        return entries.filter { calendar.isDateInYesterday($0.timestamp) }.reversed()
    }

    /// Group entries by day
    func groupedByDay() -> [(date: Date, entries: [HistoryEntry])] {
        loadIfNeeded()
        let calendar = Calendar.current
        var groups: [DateComponents: [HistoryEntry]] = [:]

        for entry in entries {
            let components = calendar.dateComponents([.year, .month, .day], from: entry.timestamp)
            groups[components, default: []].append(entry)
        }

        return groups.map { (key, entries) in
            let date = calendar.date(from: key) ?? Date()
            return (date: date, entries: entries.reversed())
        }
        .sorted { $0.date > $1.date } // Most recent day first
    }

    func totalFilmsLogged() -> Int {
        loadIfNeeded()
        return entries.count
    }

    func uniqueDirectors() -> Int {
        loadIfNeeded()
        return Set(entries.map { $0.director }).subtracting([""]).count
    }

    // MARK: - Save

    private func save() {
        _ = pruneEntries()
        let data = try? JSONEncoder().encode(entries)
        try? data?.write(to: historyFile, options: .atomic)
    }

    @discardableResult
    private func pruneEntries(referenceDate: Date = Date()) -> Bool {
        let cutoff = referenceDate.addingTimeInterval(-RetentionPolicy.maxAge)
        let sorted = entries.sorted { $0.timestamp < $1.timestamp }
        let byAge = sorted.filter { $0.timestamp >= cutoff }
        let pruned: [HistoryEntry]
        if byAge.count > RetentionPolicy.maxEntries {
            pruned = Array(byAge.suffix(RetentionPolicy.maxEntries))
        } else {
            pruned = byAge
        }

        let changed = pruned != entries
        entries = pruned
        return changed
    }
}

// MARK: - Model

struct HistoryEntry: Codable, Identifiable, Equatable {
    let id: String
    let title: String
    let year: String
    let director: String
    let composer: String
    let runtime: String
    let posterURL: String?
    let timestamp: Date

    var displayTitle: String {
        year.isEmpty ? title : "\(title) (\(year))"
    }

    var timeString: String {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f.string(from: timestamp)
    }
}
