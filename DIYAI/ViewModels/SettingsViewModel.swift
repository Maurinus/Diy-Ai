import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var debugProEnabled: Bool
    @Published var message: String?

    private let entitlementManager: EntitlementManager
    private let repairAdvisorService: RepairAdvisorService
    private let sessionManager: SessionManager

    init(entitlementManager: EntitlementManager, repairAdvisorService: RepairAdvisorService, sessionManager: SessionManager) {
        self.entitlementManager = entitlementManager
        self.repairAdvisorService = repairAdvisorService
        self.sessionManager = sessionManager
        self.debugProEnabled = entitlementManager.debugProOverride
    }

    func toggleDebugPro(_ enabled: Bool) {
        entitlementManager.debugProOverride = enabled
        debugProEnabled = enabled
    }

    func resetOnboarding() {
        UserDefaults.standard.set(false, forKey: "hasSeenOnboarding")
        message = "Onboarding will show on next launch."
    }

    func clearCache() {
        repairAdvisorService.clearCache()
        message = "Local cache cleared."
    }

    func signOut() async {
        await sessionManager.signOut()
    }
}
