import SwiftUI

/// Date eyebrow, "My journal" title, privacy line and the New Log button.
struct JournalHeroView: View {
    let onNewLog: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            Text(Date.now, format: .dateTime.weekday(.wide).day().month(.wide))
                .font(.journalEyebrow)
                .textCase(.uppercase)
                .tracking(Typography.eyebrowTracking)
                .foregroundStyle(.journalMuted)
            Text("My journal")
                .font(.journalLargeTitle)
                .foregroundStyle(.journalInk)
                .accessibilityAddTraits(.isHeader)
            PrivacyLineView()
            Button("New Log", systemImage: "plus", action: onNewLog)
                .buttonStyle(NewLogButtonStyle())
                .padding(.top, Spacing.xs)
                .padding(.trailing, Sizing.newLogPressedOffset)
                .accessibilityIdentifier("newLogButton")
        }
        .padding(.top, Spacing.section)
    }
}

/// Lock + "Private on this iPhone".
struct PrivacyLineView: View {
    var body: some View {
        Label("Private on this iPhone", systemImage: "lock")
            .font(.footnote)
            .foregroundStyle(.journalMuted)
    }
}

#Preview {
    JournalHeroView(onNewLog: {})
        .padding()
        .background(.journalPaper)
}

#Preview("Accessibility size") {
    JournalHeroView(onNewLog: {})
        .padding()
        .environment(\.dynamicTypeSize, .accessibility3)
}
