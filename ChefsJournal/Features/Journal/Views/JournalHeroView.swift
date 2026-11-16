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

/// Lock + "Private on this iPhone", or the synced variant when iCloud sync is on.
struct PrivacyLineView: View {
    @AppStorage(PreferenceKey.iCloudSyncEnabled) private var isSyncEnabled = false

    var body: some View {
        Label(isSyncActive ? "Private, synced with iCloud" : "Private on this iPhone",
              systemImage: isSyncActive ? "icloud" : "lock")
            .font(.footnote)
            .foregroundStyle(.journalMuted)
    }

    private var isSyncActive: Bool {
        CloudSyncConfiguration.isAvailable && isSyncEnabled
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
