import SwiftUI

@main
struct DIYAIApp: App {
    @StateObject private var container: AppContainer
    @StateObject private var sessionManager: SessionManager

    init() {
        let container = AppContainer()
        _container = StateObject(wrappedValue: container)
        _sessionManager = StateObject(wrappedValue: SessionManager(supabaseService: container.supabaseService, entitlementManager: container.entitlementManager))
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(container)
                .environmentObject(sessionManager)
                .environmentObject(container.entitlementManager)
                .environmentObject(container.locationService)
                .onOpenURL { url in
                    Task {
                        await sessionManager.handleOpenURL(url)
                    }
                }
        }
    }
}
