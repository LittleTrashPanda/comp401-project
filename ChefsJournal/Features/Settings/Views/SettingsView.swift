import SwiftUI

struct SettingsView: View {
    let store: any JournalStoreProtocol

    @AppStorage(PreferenceKey.iCloudSyncEnabled) private var isSyncEnabled = false
    @AppStorage(PreferenceKey.insightsOptIn) private var isInsightsOptedIn = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    PrivacyCardView()
                }
                Section("Journal") {
                    NavigationLink(value: SettingsRoute.diners) {
                        Label("Diners", systemImage: "person.2")
                    }
                }
                Section("Your data") {
                    SettingsRow(route: .backup, title: "Backup & Sync", systemImage: "icloud",
                                detail: CloudSyncConfiguration.isAvailable && isSyncEnabled ? "On" : "Off")
                    SettingsRow(route: .export, title: "Export", systemImage: "square.and.arrow.down", detail: "CSV or PDF")
                    SettingsRow(route: .privacy, title: "Privacy & Insights", systemImage: "lock",
                                detail: isInsightsOptedIn ? "Contribution on" : "Contribution off")
                }
            }
            .scrollContentBackground(.hidden)
            .background(.journalPaper)
            .navigationTitle("Settings")
            .navigationDestination(for: SettingsRoute.self) { route in
                switch route {
                case .diners: DinersView(store: store)
                case .backup: BackupView()
                case .export: ExportView()
                case .privacy: PrivacyInsightsView()
                }
            }
        }
    }
}

private struct SettingsRow: View {
    let route: SettingsRoute
    let title: LocalizedStringKey
    let systemImage: String
    let detail: LocalizedStringKey

    var body: some View {
        NavigationLink(value: route) {
            LabeledContent {
                Text(detail)
            } label: {
                Label(title, systemImage: systemImage)
            }
        }
    }
}

/// Lock icon and the private-by-design promise.
struct PrivacyCardView: View {
    var body: some View {
        HStack(alignment: .top, spacing: Spacing.s) {
            Image(systemName: "lock")
                .font(.title2)
                .foregroundStyle(.journalCobalt)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                PrivacyLineView()
                    .font(.headline)
                    .foregroundStyle(.journalInk)
                Text("Chef's Journal keeps your blunt notes to yourself. No account, no profile, no public scores.")
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.footnote)
                    .foregroundStyle(.journalMuted)
            }
        }
        .padding(.vertical, Spacing.xs)
        .accessibilityElement(children: .combine)
    }
}

#Preview("Settings") {
    let container = PreviewData.makeContainer()
    SettingsView(store: JournalStore(modelContext: container.mainContext))
        .modelContainer(container)
}

#Preview("Dark, accessibility size") {
    let container = PreviewData.makeContainer()
    SettingsView(store: JournalStore(modelContext: container.mainContext))
        .modelContainer(container)
        .preferredColorScheme(.dark)
        .environment(\.dynamicTypeSize, .accessibility3)
}
