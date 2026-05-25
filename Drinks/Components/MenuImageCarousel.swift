import SwiftUI

struct MenuImageCarousel: View {
    let images: [MenuImage]
    var height: CGFloat = 420

    @State private var selectedIndex = 0

    var body: some View {
        VStack(spacing: AppSpacing.sm) {
            TabView(selection: $selectedIndex) {
                ForEach(Array(images.enumerated()), id: \.element.id) { index, image in
                    AsyncImageView(
                        url: image.imageURL,
                        cornerRadius: AppSpacing.cardRadius,
                        showGradientOverlay: false
                    )
                    .frame(height: height)
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: height)

            if images.count > 1 {
                HStack(spacing: AppSpacing.xs) {
                    ForEach(0..<images.count, id: \.self) { index in
                        Circle()
                            .fill(index == selectedIndex ? AppColors.accent : AppColors.surfaceHighlight)
                            .frame(width: index == selectedIndex ? 8 : 6, height: index == selectedIndex ? 8 : 6)
                            .animation(.easeOut(duration: 0.2), value: selectedIndex)
                    }
                }
            }
        }
    }
}

#Preview {
    MenuImageCarousel(
        images: [
            MenuImage(
                id: UUID(),
                menuVersionID: UUID(),
                storagePath: "preview/1.jpg",
                imageURL: MockDataService.featuredCocktail.imageURL,
                sortOrder: 0,
                ocrRawText: nil
            )
        ]
    )
    .padding()
    .screenBackground()
    .preferredColorScheme(.dark)
}
