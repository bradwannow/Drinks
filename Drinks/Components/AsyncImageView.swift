import SwiftUI

struct AsyncImageView: View {
    let url: URL?
    var contentMode: ContentMode = .fill
    var cornerRadius: CGFloat = 0
    var showGradientOverlay: Bool = false

    var body: some View {
        Group {
            if let url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        placeholder
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: contentMode)
                    case .failure:
                        failureView
                    @unknown default:
                        placeholder
                    }
                }
            } else {
                failureView
            }
        }
        .overlay {
            if showGradientOverlay {
                AppColors.cardOverlay
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }

    private var placeholder: some View {
        ZStack {
            AppColors.surfaceHighlight
            ProgressView()
                .tint(AppColors.accent)
        }
    }

    private var failureView: some View {
        ZStack {
            AppColors.surfaceHighlight
            Image(systemName: "wineglass")
                .font(.title2)
                .foregroundStyle(AppColors.textTertiary)
        }
    }
}

#Preview {
    AsyncImageView(
        url: MockDataService.featuredCocktail.imageURL,
        cornerRadius: AppSpacing.cardRadius,
        showGradientOverlay: true
    )
    .frame(height: 200)
    .padding()
    .screenBackground()
    .preferredColorScheme(.dark)
}
