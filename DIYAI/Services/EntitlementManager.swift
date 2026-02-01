import Foundation

@MainActor
final class EntitlementManager: ObservableObject {
    @Published private(set) var isPro: Bool = false
    @Published var debugProOverride: Bool {
        didSet {
            UserDefaults.standard.set(debugProOverride, forKey: "debugProOverride")
            updateEffectivePro()
        }
    }

    private var profile: Profile?

    init() {
        self.debugProOverride = UserDefaults.standard.bool(forKey: "debugProOverride")
    }

    func updateFromProfile(_ profile: Profile?) {
        self.profile = profile
        updateEffectivePro()
    }

    private func updateEffectivePro() {
        let profilePro = profile?.isPro ?? false
        isPro = profilePro || debugProOverride
    }

    var dailyLimit: Int {
        isPro ? 50 : 5
    }
}
