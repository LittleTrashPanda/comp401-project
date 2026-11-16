import SwiftUI

/// The signature cobalt Taste | Value block.
struct ScorePairView: View {
    enum Size {
        case regular
        case large
    }

    let taste: Int
    let value: Int
    var size: Size = .regular

    var body: some View {
        HStack(spacing: 0) {
            column(title: "Taste", score: taste)
            Rectangle()
                .fill(.journalPaper.opacity(Layout.disabledOpacity))
                .frame(width: Layout.hairline)
            column(title: "Value", score: value)
        }
        .fixedSize(horizontal: false, vertical: true)
        .background(.journalCobalt, in: .rect(cornerRadius: Radius.small))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Taste \(taste) out of 10, value \(value) out of 10"))
    }

    private func column(title: LocalizedStringKey, score: Int) -> some View {
        VStack(spacing: Spacing.xxs) {
            Text(title)
                .font(.caption2.weight(.semibold))
                .textCase(.uppercase)
                .tracking(Typography.eyebrowTracking)
            Text(score, format: .number)
                .font(size == .large ? .journalLargeScore : .journalScore)
        }
        .foregroundStyle(.white)
        .padding(.vertical, size == .large ? Spacing.s : Spacing.xs)
        .padding(.horizontal, size == .large ? Spacing.m : Spacing.s)
        .frame(maxWidth: size == .large ? .infinity : nil)
    }
}

#Preview("Regular and large") {
    VStack(spacing: Spacing.m) {
        ScorePairView(taste: 7, value: 9)
        ScorePairView(taste: 10, value: 6, size: .large)
    }
    .padding()
    .background(.journalPaper)
}

#Preview("Accessibility size") {
    VStack(spacing: Spacing.m) {
        ScorePairView(taste: 7, value: 9)
        ScorePairView(taste: 10, value: 6, size: .large)
    }
    .padding()
    .environment(\.dynamicTypeSize, .accessibility3)
}
