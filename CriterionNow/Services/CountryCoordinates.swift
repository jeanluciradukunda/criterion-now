import Foundation

/// Latitude/longitude for country centers — used to position posters on the globe
struct CountryCoordinates {
    static let lookup: [String: (lat: Double, lng: Double)] = [
        // Major film-producing countries
        "United States": (39.8, -98.5),
        "USA": (39.8, -98.5),
        "U.S.": (39.8, -98.5),
        "France": (46.6, 2.2),
        "Japan": (36.2, 138.3),
        "Italy": (42.5, 12.5),
        "United Kingdom": (54.0, -2.0),
        "UK": (54.0, -2.0),
        "Britain": (54.0, -2.0),
        "Germany": (51.2, 10.4),
        "West Germany": (51.2, 10.4),
        "Soviet Union": (55.8, 37.6),
        "USSR": (55.8, 37.6),
        "Russia": (55.8, 37.6),
        "Spain": (40.5, -3.7),
        "Sweden": (62.0, 15.0),
        "Denmark": (56.3, 9.5),
        "India": (20.6, 78.9),
        "China": (35.9, 104.2),
        "Hong Kong": (22.3, 114.2),
        "South Korea": (35.9, 127.8),
        "Korea": (35.9, 127.8),
        "Taiwan": (23.7, 121.0),
        "Brazil": (-14.2, -51.9),
        "Mexico": (23.6, -102.5),
        "Argentina": (-38.4, -63.6),
        "Iran": (32.4, 53.7),
        "Turkey": (38.9, 35.2),
        "Poland": (51.9, 19.1),
        "Czech Republic": (49.8, 15.5),
        "Czechoslovakia": (49.8, 15.5),
        "Hungary": (47.2, 19.5),
        "Greece": (39.1, 21.8),
        "Portugal": (39.4, -8.2),
        "Belgium": (50.5, 4.5),
        "Netherlands": (52.1, 5.3),
        "Switzerland": (46.8, 8.2),
        "Austria": (47.5, 14.6),
        "Norway": (60.5, 8.5),
        "Finland": (61.9, 25.7),
        "Ireland": (53.1, -7.7),
        "Canada": (56.1, -106.3),
        "Australia": (-25.3, 133.8),
        "New Zealand": (-40.9, 174.9),
        "Egypt": (26.8, 30.8),
        "South Africa": (-30.6, 22.9),
        "Nigeria": (9.1, 8.7),
        "Senegal": (14.5, -14.5),
        "Morocco": (31.8, -7.1),
        "Algeria": (28.0, 1.7),
        "Tunisia": (33.9, 9.5),
        "Israel": (31.0, 34.9),
        "Lebanon": (33.9, 35.9),
        "Palestine": (31.9, 35.2),
        "Thailand": (15.9, 100.9),
        "Vietnam": (14.1, 108.3),
        "Philippines": (12.9, 121.8),
        "Indonesia": (-0.8, 113.9),
        "Malaysia": (4.2, 101.9),
        "Singapore": (1.4, 103.8),
        "Cuba": (21.5, -77.8),
        "Colombia": (4.6, -74.3),
        "Chile": (-35.7, -71.5),
        "Peru": (-9.2, -75.0),
        "Romania": (45.9, 24.9),
        "Bulgaria": (42.7, 25.5),
        "Serbia": (44.0, 21.0),
        "Yugoslavia": (44.0, 21.0),
        "Croatia": (45.1, 15.2),
        "Bosnia": (43.9, 17.7),
        "Georgia": (42.3, 43.4),
        "Armenia": (40.1, 45.0),
        "Kazakhstan": (48.0, 68.0),
        "Iceland": (64.9, -19.0),
        "Luxembourg": (49.8, 6.1),
        "Lithuania": (55.2, 23.9),
        "Latvia": (56.9, 24.1),
        "Estonia": (58.6, 25.0),
        "Ukraine": (48.4, 31.2),
        "Myanmar": (21.9, 95.9),
        "Cambodia": (12.6, 104.9),
        "Nepal": (28.4, 84.1),
        "Sri Lanka": (7.9, 80.8),
        "Pakistan": (30.4, 69.3),
        "Bangladesh": (23.7, 90.4),
        "Afghanistan": (33.9, 67.7),
        "Iraq": (33.2, 43.7),
        "Kenya": (-0.02, 37.9),
        "Ethiopia": (9.1, 40.5),
        "Ghana": (7.9, -1.0),
        "Burkina Faso": (12.4, -1.6),
        "Mali": (17.6, -4.0),
        "Madagascar": (-18.8, 46.9),
        "Ivory Coast": (7.5, -5.5),
        "Côte d'Ivoire": (7.5, -5.5),
        "Congo": (-4.0, 21.8),
        "Mauritania": (21.0, -10.9),
    ]

    /// Find coordinates for a country string (handles partial matches)
    static func find(_ country: String) -> (lat: Double, lng: Double)? {
        let trimmed = country.trimmingCharacters(in: .whitespaces)

        // Exact match first
        if let coords = lookup[trimmed] { return coords }

        // Case-insensitive
        let lower = trimmed.lowercased()
        for (key, value) in lookup {
            if key.lowercased() == lower { return value }
        }

        // Contains match
        for (key, value) in lookup {
            if lower.contains(key.lowercased()) || key.lowercased().contains(lower) {
                return value
            }
        }

        return nil
    }

    /// Convert lat/lng to 3D position on a sphere of given radius
    static func toSpherePosition(lat: Double, lng: Double, radius: Double) -> (x: Float, y: Float, z: Float) {
        let latRad = lat * .pi / 180.0
        let lngRad = lng * .pi / 180.0

        let x = Float(radius * cos(latRad) * cos(lngRad))
        let y = Float(radius * sin(latRad))
        let z = Float(-radius * cos(latRad) * sin(lngRad))

        return (x, y, z)
    }
}
