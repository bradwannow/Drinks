import SwiftUI

struct SearchFilterBar: View {
    let availableSpirits: [String]
    let availableNeighborhoods: [String]
    @Binding var filters: SearchFilters
    let onFilterChange: () -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.sm) {
                spiritMenu
                neighborhoodMenu

                ForEach(SearchFilterToggle.allCases) { toggle in
                    FilterChip(
                        title: toggle.title,
                        icon: toggle.icon,
                        isSelected: isSelected(toggle)
                    ) {
                        filters.toggle(toggle)
                        onFilterChange()
                    }
                }

                if filters.isActive {
                    FilterChip(title: "Clear", icon: "xmark") {
                        filters.clear()
                        onFilterChange()
                    }
                }
            }
            .padding(.vertical, AppSpacing.xxs)
        }
    }

    private var spiritMenu: some View {
        Menu {
            if filters.spirit != nil {
                Button("All Spirits") {
                    filters.spirit = nil
                    onFilterChange()
                }
            }

            ForEach(availableSpirits, id: \.self) { spirit in
                Button {
                    filters.applySpirit(spirit)
                    onFilterChange()
                } label: {
                    if filters.spirit == spirit {
                        Label(spirit, systemImage: "checkmark")
                    } else {
                        Text(spirit)
                    }
                }
            }
        } label: {
            FilterChip(
                title: filters.spirit ?? "Spirit",
                icon: "drop.fill",
                isSelected: filters.spirit != nil
            )
        }
    }

    private var neighborhoodMenu: some View {
        Menu {
            if filters.neighborhood != nil {
                Button("All Neighborhoods") {
                    filters.neighborhood = nil
                    onFilterChange()
                }
            }

            ForEach(availableNeighborhoods, id: \.self) { neighborhood in
                Button {
                    filters.applyNeighborhood(neighborhood)
                    onFilterChange()
                } label: {
                    if filters.neighborhood == neighborhood {
                        Label(neighborhood, systemImage: "checkmark")
                    } else {
                        Text(neighborhood)
                    }
                }
            }
        } label: {
            FilterChip(
                title: filters.neighborhood ?? "Neighborhood",
                icon: "mappin.circle.fill",
                isSelected: filters.neighborhood != nil
            )
        }
    }

    private func isSelected(_ toggle: SearchFilterToggle) -> Bool {
        switch toggle {
        case .happyHourNow: return filters.happyHourNow
        case .featuredOnly: return filters.featuredOnly
        case .seasonalOnly: return filters.seasonalOnly
        case .savedOnly: return filters.savedOnly
        }
    }
}

#Preview {
    SearchFilterBar(
        availableSpirits: ["Gin", "Bourbon", "Rum"],
        availableNeighborhoods: ["Wicker Park", "West Loop"],
        filters: .constant(SearchFilters(happyHourNow: true)),
        onFilterChange: {}
    )
    .padding()
    .screenBackground()
    .preferredColorScheme(.dark)
}
