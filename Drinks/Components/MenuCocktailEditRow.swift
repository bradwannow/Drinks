import SwiftUI

struct MenuCocktailEditRow: View {
    @Binding var cocktail: DraftMenuCocktail
    var onDelete: (() -> Void)?

    var body: some View {
        PourCard {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                        TextField("Cocktail name", text: $cocktail.name)
                            .font(.system(size: 16, weight: .semibold, design: .serif))
                            .foregroundStyle(AppColors.textPrimary)
                            .onChange(of: cocktail.name) { _, _ in
                                cocktail.isManuallyEdited = true
                            }

                        if cocktail.hasLowConfidence {
                            Label("Low OCR confidence — please verify", systemImage: "exclamationmark.triangle.fill")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(AppColors.accentSecondary)
                        }
                    }

                    Spacer()

                    if let onDelete {
                        Button(action: onDelete) {
                            Image(systemName: "trash")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(AppColors.textTertiary)
                        }
                        .buttonStyle(.plain)
                    }
                }

                TextField("Description (optional)", text: $cocktail.description, axis: .vertical)
                    .font(.system(size: 14))
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(2...4)
                    .onChange(of: cocktail.description) { _, _ in
                        cocktail.isManuallyEdited = true
                    }

                TextField("Price", text: Binding(
                    get: { cocktail.priceText ?? "" },
                    set: { cocktail.priceText = $0.nilIfEmpty; cocktail.isManuallyEdited = true }
                ))
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(AppColors.accent)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}

private extension DraftMenuCocktail {
    var hasLowConfidence: Bool {
        guard let ocrConfidence else { return false }
        return ocrConfidence < 0.6 && !isManuallyEdited
    }
}

#Preview {
    MenuCocktailEditRow(
        cocktail: .constant(
            DraftMenuCocktail(name: "Smoked Negroni", description: "Mezcal, campari, sweet vermouth", priceText: "$16")
        ),
        onDelete: {}
    )
    .padding()
    .screenBackground()
    .preferredColorScheme(.dark)
}
