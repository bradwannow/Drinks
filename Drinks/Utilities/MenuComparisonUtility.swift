import Foundation

enum MenuComparisonUtility {
    static func compare(
        current: [MenuCocktailEntry],
        previous: [MenuCocktailEntry],
        historicalSeasonal: [MenuCocktailEntry] = []
    ) -> MenuComparison {
        let currentNames = normalizedNames(from: current)
        let previousNames = normalizedNames(from: previous)
        let historicalNames = Set(normalizedNames(from: historicalSeasonal))

        let added = currentNames.subtracting(previousNames).sorted()
        let removed = previousNames.subtracting(currentNames).sorted()
        let seasonalReturns = added.filter { historicalNames.contains($0) }.sorted()
        let netAdded = added.filter { !seasonalReturns.contains($0) }

        return MenuComparison(
            added: netAdded,
            removed: removed,
            seasonalReturns: seasonalReturns
        )
    }

    static func recentlyAdded(from comparison: MenuComparison, limit: Int = 6) -> [String] {
        Array((comparison.added + comparison.seasonalReturns).prefix(limit))
    }

    private static func normalizedNames(from entries: [MenuCocktailEntry]) -> Set<String> {
        Set(
            entries
                .map { normalize($0.name) }
                .filter { !$0.isEmpty }
        )
    }

    private static func normalize(_ name: String) -> String {
        name
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
    }
}
