import Foundation

actor TMDBService {
    private var bearerToken: String { KeychainService.tmdbBearerToken }
    private let baseURL = "https://api.themoviedb.org/3"
    private let imageBaseURL = "https://image.tmdb.org/t/p"
    private let cache = CacheService.shared

    func fetchMovieDetails(title: String) async throws -> (TMDBMovieDetail?, URL?) {
        if let cached = await cache.getCachedTMDB(title: title) {
            return cached
        }

        // Try the title as-is first, then variants if no results
        let queries = buildQueryVariants(title)

        var firstResult: TMDBSearchResult?
        for query in queries {
            if let result = try await searchTMDB(query: query) {
                firstResult = result
                break
            }
        }

        guard let match = firstResult else {
            await cache.cacheTMDB(title: title, detail: nil, posterURL: nil)
            return (nil, nil)
        }

        // Fetch full details
        let detailURL = URL(string: "\(baseURL)/movie/\(match.id)?append_to_response=credits")!
        var detailRequest = URLRequest(url: detailURL)
        detailRequest.addValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        detailRequest.addValue("application/json", forHTTPHeaderField: "Accept")

        let (detailData, _) = try await URLSession.shared.data(for: detailRequest)
        let detail = try JSONDecoder().decode(TMDBMovieDetail.self, from: detailData)

        let posterURL = detail.posterPath.flatMap { URL(string: "\(imageBaseURL)/w500\($0)") }

        await cache.cacheTMDB(title: title, detail: detail, posterURL: posterURL)
        return (detail, posterURL)
    }

    // MARK: - Search with single query

    private func searchTMDB(query: String) async throws -> TMDBSearchResult? {
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "&+")
        let encoded = query.addingPercentEncoding(withAllowedCharacters: allowed) ?? query
        let url = URL(string: "\(baseURL)/search/movie?query=\(encoded)")!

        var request = URLRequest(url: url)
        request.addValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(TMDBSearchResponse.self, from: data)
        return response.results.first
    }

    // MARK: - Query Variants

    /// Build alternative search queries to handle "and" vs "&", articles, etc.
    private func buildQueryVariants(_ title: String) -> [String] {
        var variants: [String] = [title]

        // "and" → "&"
        if title.lowercased().contains(" and ") {
            variants.append(title.replacingOccurrences(of: " and ", with: " & ", options: .caseInsensitive))
            variants.append(title.replacingOccurrences(of: " and ", with: " ", options: .caseInsensitive))
        }

        // "&" → "and"
        if title.contains("&") {
            variants.append(title.replacingOccurrences(of: "&", with: "and"))
            variants.append(title.replacingOccurrences(of: " & ", with: " "))
        }

        // Drop leading "The" / "A"
        let lower = title.lowercased()
        if lower.hasPrefix("the ") {
            variants.append(String(title.dropFirst(4)))
        } else if lower.hasPrefix("a ") {
            variants.append(String(title.dropFirst(2)))
        }

        return variants
    }
}
