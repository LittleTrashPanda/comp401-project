import SwiftUI

struct BackupView: View {
    @StateObject private var viewModel = BackupViewModel()

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: Spacing.s) {
                    Image(systemName: "icloud")
                        .font(.largeTitle)
                        .foregroundStyle(.journalCobalt)
                        .accessibilityHidden(true)
                    Text("Keep your journal on all your devices")
                        .font(.journalCardTitle)
                    Text("Sync uses your own private iCloud database. Nobody else, including us, can read it.")
                        .font(.callout)
                        .foregroundStyle(.journalMuted)
                }
                .padding(.vertical, Spacing.xs)
            }
            Section {
                Toggle("iCloud sync", isOn: Binding(get: { viewModel.isSyncEnabled }, set: viewModel.setSyncEnabled))
                    .disabled(!viewModel.isSyncAvailable)
                Label(viewModel.statusText, systemImage: statusSymbol)
                    .font(.footnote)
                    .foregroundStyle(statusColor)
            } footer: {
                if !viewModel.isSyncAvailable {
                    Text("Sync needs an iCloud container from an Apple Developer team. Your journal stays on this iPhone until it’s set up.")
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(.journalPaper)
        .navigationTitle("Backup & Sync")
        .task { await viewModel.observe() }
    }

    private var statusSymbol: String {
        switch viewModel.status {
        case .synced: "checkmark.icloud"
        case .failed: "exclamationmark.icloud"
        case .syncing: "arrow.triangle.2.circlepath.icloud"
        case .off, .unavailable: "lock"
        }
    }

    private var statusColor: Color {
        switch viewModel.status {
        case .synced: .journalSuccess
        case .failed: .journalTomato
        default: .journalMuted
        }
    }
}

#Preview {
    NavigationStack { BackupView() }
}

#Preview("Accessibility size") {
    NavigationStack { BackupView() }
        .environment(\.dynamicTypeSize, .accessibility3)
}
