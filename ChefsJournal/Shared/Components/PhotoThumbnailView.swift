import SwiftUI
import UIKit

/// A dish photo cropped to a circle or arch, or an initials placeholder when there's no photo.
struct PhotoThumbnailView: View {
    enum Shape {
        case circle
        case arched
    }

    let photoData: Data?
    let placeholderText: String
    var shape: Shape = .circle
    var side: CGFloat = Layout.visitRowPhoto

    @Environment(\.displayScale) private var displayScale
    @State private var thumbnail: UIImage?

    var body: some View {
        content
            .frame(width: side, height: side)
            .clipShape(clipShape)
            .accessibilityHidden(true)
            .task(id: photoData) {
                thumbnail = await Self.makeThumbnail(from: photoData, side: side * displayScale)
            }
    }

    @ViewBuilder
    private var content: some View {
        if let thumbnail {
            Image(uiImage: thumbnail)
                .resizable()
                .scaledToFill()
        } else {
            ZStack {
                Rectangle().fill(.journalCobaltSoft)
                Text(placeholderText)
                    .font(.system(.headline, design: .serif))
                    .foregroundStyle(.journalCobalt)
                    .minimumScaleFactor(Typography.minimumScaleFactor)
            }
        }
    }

    private var clipShape: some SwiftUI.Shape {
        switch shape {
        case .circle:
            UnevenRoundedRectangle(cornerRadii: .init(topLeading: side / 2, bottomLeading: side / 2,
                                                      bottomTrailing: side / 2, topTrailing: side / 2))
        case .arched:
            UnevenRoundedRectangle(cornerRadii: .init(topLeading: Radius.arch, bottomLeading: Radius.small,
                                                      bottomTrailing: Radius.small, topTrailing: Radius.arch))
        }
    }

    private static func makeThumbnail(from photoData: Data?, side: CGFloat) async -> UIImage? {
        guard let photoData else { return nil }
        let pixelSide = side
        return await Task.detached(priority: .utility) {
            UIImage(data: photoData)?.preparingThumbnail(of: CGSize(width: pixelSide, height: pixelSide))
        }.value
    }
}

#Preview("Placeholders") {
    HStack(spacing: Spacing.m) {
        PhotoThumbnailView(photoData: nil, placeholderText: "BI")
        PhotoThumbnailView(photoData: nil, placeholderText: "S", shape: .arched, side: Layout.dishRowPhoto)
    }
    .padding()
}

#Preview("Accessibility size") {
    PhotoThumbnailView(photoData: nil, placeholderText: "HS")
        .padding()
        .environment(\.dynamicTypeSize, .accessibility3)
}
