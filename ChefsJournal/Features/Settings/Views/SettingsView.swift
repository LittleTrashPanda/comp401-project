import SwiftUI

struct SettingsView: View {
    let store: any JournalStoreProtocol

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
            }
            .scrollContentBackground(.hidden)
            .background(.journalPaper)
            .navigationTitle("Settings")
            .navigationDestination(for: SettingsRoute.self) { route in
                switch route {
                case .diners: DinersView(store: store)
                }
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
