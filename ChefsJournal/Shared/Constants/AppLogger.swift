import Foundation
import os

extension Logger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "ChefsJournal"

    static let persistence = Logger(subsystem: subsystem, category: "Persistence")
    static let photos = Logger(subsystem: subsystem, category: "Photos")
    static let export = Logger(subsystem: subsystem, category: "Export")
    static let sync = Logger(subsystem: subsystem, category: "Sync")
}
