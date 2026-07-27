import MapKit

/// Suggests places for the location picker.
///
/// This uses `MKLocalSearch` rather than `MKLocalSearchCompleter`: a completion
/// carries no coordinate, so there is no way to verify it falls inside Surabaya,
/// and the completer's region is only a ranking hint. Map items carry a location,
/// so out-of-region results can be dropped outright.
@MainActor
@Observable
final class LocationSuggestionProvider {
    private(set) var suggestions: [SearchSuggestion] = []

    private var searchTask: Task<Void, Never>?

    func update(query: String) {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        searchTask?.cancel()

        guard trimmedQuery.count >= 3 else {
            suggestions = []
            return
        }

        searchTask = Task {
            // MKLocalSearch is heavier than a completer, so wait for a pause in typing.
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }

            let results = await Self.searchSurabaya(for: trimmedQuery)
            guard !Task.isCancelled else { return }

            suggestions = results
        }
    }

    func clear() {
        searchTask?.cancel()
        suggestions = []
    }

    private static func searchSurabaya(for query: String) async -> [SearchSuggestion] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = [.address, .pointOfInterest]
        request.region = .surabaya
        request.regionPriority = .required

        guard let response = try? await MKLocalSearch(request: request).start() else {
            return []
        }

        return response.mapItems
            .filter { MKCoordinateRegion.surabaya.contains($0.location.coordinate) }
            .prefix(5)
            .map { mapItem in
                SearchSuggestion(
                    title: mapItem.name ?? query,
                    subtitle: mapItem.address?.shortAddress ?? ""
                )
            }
    }
}
