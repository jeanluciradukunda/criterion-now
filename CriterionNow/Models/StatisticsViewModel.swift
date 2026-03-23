import SwiftUI

struct CountryFilmGroup: Identifiable {
    let id = UUID()
    let country: String
    let films: [LibraryMovie]
    let lat: Double
    let lng: Double
    var count: Int { films.count }
}

struct DirectorGroup: Identifiable {
    let id = UUID()
    let name: String
    let count: Int
}

struct DecadeGroup: Identifiable {
    let id = UUID()
    let decade: String
    let count: Int
}

@MainActor
class StatisticsViewModel: ObservableObject {
    @Published var countryGroups: [CountryFilmGroup] = []
    @Published var directorGroups: [DirectorGroup] = []
    @Published var decadeGroups: [DecadeGroup] = []
    @Published var selectedCountry: CountryFilmGroup?
    @Published var totalFilms: Int = 0
    @Published var totalCountries: Int = 0
    @Published var yearRange: String = ""

    func load(from movies: [LibraryMovie]) {
        let films = movies.filter { !$0.itemType.isCollection }
        totalFilms = films.count

        // Country grouping — use primaryCountry from TMDB, deterministic
        var countryMap: [String: [LibraryMovie]] = [:]
        for film in films {
            let country = film.primaryCountry.isEmpty ? "Unknown" : film.primaryCountry
            countryMap[country, default: []].append(film)
        }

        countryGroups = countryMap.compactMap { country, films in
            guard let coords = CountryCoordinates.find(country) else {
                if country == "Unknown" { return nil }
                return CountryFilmGroup(country: country, films: films, lat: 0, lng: 0)
            }
            return CountryFilmGroup(country: country, films: films, lat: coords.lat, lng: coords.lng)
        }
        .sorted { $0.count > $1.count }

        totalCountries = countryGroups.count

        // Director grouping
        var dirMap: [String: Int] = [:]
        for film in films where !film.director.isEmpty {
            dirMap[film.director, default: 0] += 1
        }
        directorGroups = dirMap.map { DirectorGroup(name: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }

        // Decade grouping
        var decMap: [String: Int] = [:]
        for film in films {
            if let year = Int(film.year), year > 1900 {
                decMap["\(year / 10 * 10)s", default: 0] += 1
            }
        }
        decadeGroups = decMap.map { DecadeGroup(decade: $0.key, count: $0.value) }
            .sorted { $0.decade < $1.decade }

        // Year range
        let years = films.compactMap { Int($0.year) }.filter { $0 > 1900 }
        if let mn = years.min(), let mx = years.max() { yearRange = "\(mn)–\(mx)" }
    }
}
