import CoreData
import Foundation

enum SyncStatus: Sendable, Hashable {
    case off
    case unavailable
    case syncing
    case synced(Date)
    case failed(String)
}

/// Turns CloudKit mirroring events into a ``SyncStatus``.
struct SyncStatusMonitor: Sendable {
    func statuses() -> AsyncStream<SyncStatus> {
        AsyncStream { continuation in
            let task = Task {
                for await notification in NotificationCenter.default.notifications(named: NSPersistentCloudKitContainer.eventChangedNotification) {
                    guard let event = notification.userInfo?[NSPersistentCloudKitContainer.eventNotificationUserInfoKey]
                            as? NSPersistentCloudKitContainer.Event else { continue }
                    continuation.yield(Self.status(endDate: event.endDate, succeeded: event.succeeded,
                                                   errorDescription: event.error?.localizedDescription))
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    static func status(endDate: Date?, succeeded: Bool, errorDescription: String?) -> SyncStatus {
        guard let endDate else { return .syncing }
        if succeeded { return .synced(endDate) }
        return .failed(errorDescription ?? String(localized: "Something went wrong."))
    }
}
