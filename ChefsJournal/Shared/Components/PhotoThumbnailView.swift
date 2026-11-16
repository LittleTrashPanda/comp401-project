import os
import SwiftUI

/// A dish photo cropped to a circle or arch, or an initials placeholder when there's no photo.
struct PhotoThumbnailView: View {
    enum Shape {
        case circle
        case arched
        /// Fills the proposed width; `side` only sets the decode size.
        case hero
    }

    let photoData: Data?
    let placeholderText: String
    var shape: Shape = .circle
    var side: CGFloat = Sizing.visitRowPhoto

    @Environment(\.displayScale) private var displayScale
    @State private var thumbnail: CGImage?

    var body: some View {
        content
            .frame(width: shape == .hero ? nil : side, height: shape == .hero ? nil : side)
            .clipShape(clipShape)
            .accessibilityHidden(true)
            .task(id: photoData) {
                thumbnail = await makeThumbnail()
            }
    }

    @ViewBuilder
    private var content: some View {
        if let thumbnail {
            Image(decorative: thumbnail, scale: displayScale)
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
        case .hero:
            UnevenRoundedRectangle(cornerRadii: .init(topLeading: Radius.large, bottomLeading: Radius.medium,
                                                      bottomTrailing: Radius.medium, topTrailing: Radius.large))
        }
    }

    private func makeThumbnail() async -> CGImage? {
        guard let photoData else { return nil }
        do {
            return try await PhotoProcessor().thumbnail(from: photoData, pointSize: side, scale: displayScale)
        } catch {
            Logger.photos.error("Thumbnail failed: \(error.localizedDescription, privacy: .public)")
            return nil
        }
    }
}

#Preview("Placeholders") {
    HStack(spacing: Spacing.m) {
        PhotoThumbnailView(photoData: nil, placeholderText: "BI")
        PhotoThumbnailView(photoData: nil, placeholderText: "S", shape: .arched, side: Sizing.dishRowPhoto)
    }
    .padding()
}

#Preview("Accessibility size") {
    PhotoThumbnailView(photoData: nil, placeholderText: "HS")
        .padding()
        .environment(\.dynamicTypeSize, .accessibility3)
}
