import Combine
import Foundation

/// Stores the anonymous-insights choice. Nothing is transmitted: there is no insights service.
@MainActor
final class PrivacyInsightsViewModel: ObservableObject {
    @Published private(set) var isOptedIn: Bool
    @Published var isConfirmingTurnOff = false

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        isOptedIn = defaults.bool(forKey: PreferenceKey.insightsOptIn)
    }

    /// Turning on is immediate; turning off asks for confirmation first.
    func setOptIn(_ optIn: Bool) {
        if optIn {
            store(true)
        } else {
            requestTurnOff()
        }
    }

    func requestTurnOff() {
        guard isOptedIn else { return }
        isConfirmingTurnOff = true
    }

    func confirmTurnOff() {
        isConfirmingTurnOff = false
        store(false)
    }

    private func store(_ optIn: Bool) {
        isOptedIn = optIn
        defaults.set(optIn, forKey: PreferenceKey.insightsOptIn)
    }
}
