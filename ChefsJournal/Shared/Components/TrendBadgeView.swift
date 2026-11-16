import SwiftUI

/// ↗ Improving, → Steady or ↘ Slipping.
struct TrendBadgeView: View {
    let trend: Trend

    var body: some View {
        Label {
            Text(title)
        } icon: {
            Image(systemName: symbolName)
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(color)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Trend: \(Text(title))"))
    }

    private var title: LocalizedStringKey {
        switch trend {
        case .improving: "Improving"
        case .steady: "Steady"
        case .slipping: "Slipping"
        }
    }

    private var symbolName: String {
        switch trend {
        case .improving: "arrow.up.right"
        case .steady: "arrow.right"
        case .slipping: "arrow.down.right"
        }
    }

    private var color: Color {
        switch trend {
        case .improving: .journalSuccess
        case .steady: .journalMuted
        case .slipping: .journalTomato
        }
    }
}

#Preview("All trends") {
    VStack(alignment: .leading, spacing: Spacing.s) {
        ForEach(Trend.allCases, id: \.self) { TrendBadgeView(trend: $0) }
    }
    .padding()
}

#Preview("Accessibility size") {
    VStack(alignment: .leading, spacing: Spacing.s) {
        ForEach(Trend.allCases, id: \.self) { TrendBadgeView(trend: $0) }
    }
    .padding()
    .environment(\.dynamicTypeSize, .accessibility3)
}
