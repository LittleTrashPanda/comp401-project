import SwiftUI

/// Tomato circular stamp showing the restaurant experience score.
struct ExperienceStampView: View {
    enum Size {
        case regular
        case compact
    }

    let score: Int
    var size: Size = .regular

    @ScaledMetric(relativeTo: .title) private var regularDiameter = Sizing.experienceStampRegular
    @ScaledMetric(relativeTo: .body) private var compactDiameter = Sizing.experienceStampCompact

    var body: some View {
        VStack(spacing: 0) {
            Text(score, format: .number)
                .font(size == .regular ? .journalLargeScore : .journalScore)
            if size == .regular {
                Text("Experience")
                    .font(.caption2.weight(.semibold))
                    .textCase(.uppercase)
                    .minimumScaleFactor(Typography.minimumScaleFactor)
                    .lineLimit(1)
            }
        }
        .foregroundStyle(.journalTomato)
        .padding(Spacing.xxs)
        .frame(width: diameter, height: diameter)
        .overlay(Circle().strokeBorder(.journalTomato, lineWidth: Sizing.stampStroke))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Experience \(score) out of 10"))
    }

    private var diameter: CGFloat {
        size == .regular ? regularDiameter : compactDiameter
    }
}

#Preview("Regular and compact") {
    HStack(spacing: Spacing.m) {
        ExperienceStampView(score: 8)
        ExperienceStampView(score: 10, size: .compact)
    }
    .padding()
    .background(.journalPaper)
}

#Preview("Accessibility size") {
    HStack(spacing: Spacing.m) {
        ExperienceStampView(score: 8)
        ExperienceStampView(score: 10, size: .compact)
    }
    .padding()
    .environment(\.dynamicTypeSize, .accessibility3)
}
