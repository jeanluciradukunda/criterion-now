import SwiftUI

@MainActor
class HistoryViewModel: ObservableObject {
    @Published var groupedEntries: [(date: Date, entries: [HistoryEntry])] = []
    @Published var totalFilms: Int = 0
    @Published var uniqueDirectors: Int = 0
    @Published var isLoaded = false

    func load() async {
        let service = HistoryService.shared
        groupedEntries = await service.groupedByDay()
        totalFilms = await service.totalFilmsLogged()
        uniqueDirectors = await service.uniqueDirectors()
        isLoaded = true
    }

    func dayLabel(for date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) { return "Today" }
        if calendar.isDateInYesterday(date) { return "Yesterday" }

        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: date)
    }
}
