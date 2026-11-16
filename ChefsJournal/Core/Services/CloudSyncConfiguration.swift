import Foundation

/// iCloud sync needs a paid developer team, an iCloud container and the CloudKit entitlement.
/// Until those exist, `containerIdentifier` stays nil and the app reports sync as unavailable.
enum CloudSyncConfiguration {
    static let containerIdentifier: String? = nil

    static var isAvailable: Bool { containerIdentifier != nil }

    /// Sync runs only when it's both configured and switched on.
    static func isActive(defaults: UserDefaults = .standard) -> Bool {
        isAvailable && defaults.bool(forKey: PreferenceKey.iCloudSyncEnabled)
    }
}
