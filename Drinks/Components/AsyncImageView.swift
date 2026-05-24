import SwiftUI

struct AsyncImageView: View {
    let url: URL?
    var contentMode: ContentMode = .fill
    var cornerRadius: CGFloat = 0
    var showGradientOverlay: Bool = false

    var body: some View {
        Color.clear
            .overlay {
                imageBody
            }
            .overlay {
                if showGradientOverlay {
                    AppColors.cardOverlay
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }

    @ViewBuilder
    private var imageBody: some View {
        if let url {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    placeholder
                case .success(let image):
                    image
                        .resizable()
                        .modifier(ImageScaling(mode: contentMode))
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

private struct ImageScaling: ViewModifier {
    let mode: ContentMode

    func body(content: Content) -> some View {
        switch mode {
        case .fill:
            content
                .scaledToFill()
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .clipped()
        case .fit:
            content
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        @unknown default:
            content
                .scaledToFill()
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .clipped()
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
