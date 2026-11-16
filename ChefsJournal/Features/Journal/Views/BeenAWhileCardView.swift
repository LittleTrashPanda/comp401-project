import SwiftUI

/// The ink "Been a while" card suggesting a favourite you haven't revisited.
struct BeenAWhileCardView: View {
    let card: BeenAWhileCard

    var body: some View {
        HStack(alignment: .center, spacing: Spacing.m) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("Been a while")
                    .font(.journalEyebrow)
                    .textCase(.uppercase)
                    .tracking(Typography.eyebrowTracking)
                    .foregroundStyle(.journalGold)
                Text(card.name)
                    .font(.journalCardTitle)
                Text(card.detail)
                    .font(.footnote)
                    .opacity(Sizing.pressedOpacity)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Image(systemName: "chevron.right")
                .foregroundStyle(.journalGold)
                .accessibilityHidden(true)
        }
        .foregroundStyle(.journalPaper)
        .padding(Spacing.m)
        .background(.journalInk, in: .rect(cornerRadius: Radius.medium))
        .overlay(RoundedRectangle(cornerRadius: Radius.medium).strokeBorder(.journalGold, lineWidth: Sizing.hairline))
        .accessibilityElement(children: .combine)
        .accessibilityHint(Text("Opens the restaurant"))
    }
}

#Preview {
    BeenAWhileCardView(card: .init(id: UUID(), name: "Hearthside Steakhouse",
                                   detail: "You rate it 8.6 on average. Last visited 3 weeks ago."))
        .padding()
}

#Preview("Accessibility size") {
    BeenAWhileCardView(card: .init(id: UUID(), name: "Hearthside Steakhouse",
                                   detail: "You rate it 8.6 on average. Last visited 3 weeks ago."))
        .padding()
        .environment(\.dynamicTypeSize, .accessibility3)
}
