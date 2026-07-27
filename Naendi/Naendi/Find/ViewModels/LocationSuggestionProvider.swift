import MapKit

@MainActor
@Observable
final class LocationSuggestionProvider: NSObject, MKLocalSearchCompleterDelegate {
    private(set) var suggestions: [SearchSuggestion] = []

    private let completer = MKLocalSearchCompleter()

    override init() {
        super.init()
        completer.resultTypes = [.address, .pointOfInterest]
        completer.region = .surabaya
        completer.regionPriority = .required
        completer.delegate = self
    }

    func update(query: String) {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)

        guard trimmedQuery.count >= 2 else {
            clear()
            return
        }

        completer.queryFragment = trimmedQuery
    }

    func clear() {
        completer.cancel()
        suggestions = []
    }

    nonisolated func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        let results = completer.results.prefix(5).map {
            SearchSuggestion(title: $0.title, subtitle: $0.subtitle)
        }
        MainActor.assumeIsolated { suggestions = results }
    }

    nonisolated func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        MainActor.assumeIsolated { suggestions = [] }
    }
}
