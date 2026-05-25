import SwiftUI
import UniformTypeIdentifiers

struct MenuImageReorderStrip: View {
    @Binding var images: [DraftMenuImage]
    var onMove: (UUID, UUID) -> Void
    var onRemove: ((UUID) -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                Text("Drag to reorder pages")
                    .captionStyle()
                Spacer()
                Text("\(images.count) photos")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(AppColors.textTertiary)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.sm) {
                    ForEach(Array(images.enumerated()), id: \.element.id) { index, item in
                        imageTile(item, index: index)
                            .draggable(item.id.uuidString) {
                                Image(uiImage: item.image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 60, height: 80)
                                    .clipShape(RoundedRectangle(cornerRadius: AppSpacing.xs, style: .continuous))
                            }
                            .dropDestination(for: String.self) { droppedIDs, _ in
                                guard let draggedID = droppedIDs.first, let sourceID = UUID(uuidString: draggedID) else {
                                    return false
                                }
                                onMove(sourceID, item.id)
                                HapticFeedback.light()
                                return true
                            }
                    }
                }
            }
        }
    }

    private func imageTile(_ item: DraftMenuImage, index: Int) -> some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: item.image)
                .resizable()
                .scaledToFill()
                .frame(width: 88, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: AppSpacing.sm, style: .continuous))
                .overlay(alignment: .bottomLeading) {
                    Text("\(index + 1)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(AppColors.background)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(AppColors.accent)
                        .clipShape(Capsule())
                        .padding(AppSpacing.xs)
                }

            if let onRemove {
                Button {
                    onRemove(item.id)
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(AppColors.textPrimary)
                        .shadow(radius: 2)
                }
                .buttonStyle(.plain)
                .offset(x: 6, y: -6)
            }
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var images: [DraftMenuImage] = []

        var body: some View {
            MenuImageReorderStrip(images: $images, onMove: { _, _ in })
                .padding()
                .screenBackground()
                .preferredColorScheme(.dark)
        }
    }
    return PreviewWrapper()
}
