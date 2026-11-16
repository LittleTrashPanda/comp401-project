import SwiftUI

/// Warning banner listing flagged dishes, or a calm "none" variant.
struct HeadsUpBannerView: View {
    /// Pre-formatted lines such as "Calzone — contains gluten (Eliza)". Empty shows the "none" variant.
    let lines: [String]

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.s) {
            Image(systemName: lines.isEmpty ? "checkmark" : "exclamationmark.triangle")
                .foregroundStyle(lines.isEmpty ? .journalSuccess : .journalTomato)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(lines.isEmpty ? "Heads-up: none" : "Heads-up")
                    .font(.headline)
                if lines.isEmpty {
                    Text("No dishes here are flagged for your diners.")
                        .font(.footnote)
                        .foregroundStyle(.journalMuted)
                } else {
                    ForEach(lines, id: \.self) { line in
                        Text(line)
                            .font(.callout)
                    }
                }
            }
            Spacer(minLength: 0)
        }
        .padding(Spacing.m)
        .background(lines.isEmpty ? Color.journalSuccess.opacity(Layout.softFillOpacity) : .journalTomatoSoft,
                    in: .rect(cornerRadius: Radius.medium))
        .accessibilityElement(children: .combine)
    }
}

#Preview("Warning") {
    HeadsUpBannerView(lines: ["Calzone — contains gluten (Eliza)", "Tiramisu — contains dairy (Liam, Eliza)"])
        .padding()
}

#Preview("None") {
    HeadsUpBannerView(lines: [])
        .padding()
}

#Preview("Accessibility size") {
    HeadsUpBannerView(lines: ["Calzone — contains gluten (Eliza)"])
        .padding()
        .environment(\.dynamicTypeSize, .accessibility3)
}
