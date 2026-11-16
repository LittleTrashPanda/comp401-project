import Combine
import Foundation

@MainActor
final class BackupViewModel: ObservableObject {
    private static let justNowInterval: TimeInterval = 60

    @Published private(set) var isSyncEnabled: Bool
    @Published var status: SyncStatus
    let isSyncAvailable: Bool

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard, isSyncAvailable: Bool = CloudSyncConfiguration.isAvailable) {
        self.defaults = defaults
        self.isSyncAvailable = isSyncAvailable
        let enabled = isSyncAvailable && defaults.bool(forKey: PreferenceKey.iCloudSyncEnabled)
        isSyncEnabled = enabled
        status = !isSyncAvailable ? .unavailable : (enabled ? .syncing : .off)
    }

    func setSyncEnabled(_ enabled: Bool) {
        guard isSyncAvailable else {
            status = .unavailable
            return
        }
        isSyncEnabled = enabled
        defaults.set(enabled, forKey: PreferenceKey.iCloudSyncEnabled)
        status = enabled ? .syncing : .off
    }

    /// Follows CloudKit events while the Backup screen is open.
    func observe(_ monitor: SyncStatusMonitor = SyncStatusMonitor()) async {
        guard isSyncEnabled else { return }
        for await update in monitor.statuses() {
            status = update
        }
    }

    var statusText: String {
        switch status {
        case .off:
            String(localized: "Your journal currently stays private on this iPhone.")
        case .unavailable:
            String(localized: "iCloud sync isn’t set up in this build of Chef's Journal.")
        case .syncing:
            String(localized: "Syncing…")
        case let .synced(date) where Date.now.timeIntervalSince(date) < Self.justNowInterval:
            String(localized: "Last synced just now")
        case let .synced(date):
            String(localized: "Last synced \(date.formatted(date: .abbreviated, time: .shortened))")
        case let .failed(reason):
            String(localized: "Sync failed: \(reason)")
        }
    }
}
