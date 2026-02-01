import Foundation

@MainActor
final class AppContainer: ObservableObject {
    let config: AppConfig
    let supabaseService: SupabaseService?
    let repairAdvisorService: RepairAdvisorService
    let storePricingService: StorePricingServiceProtocol
    let entitlementManager: EntitlementManager
    let cacheStore: CacheStore
    let locationService: LocationService
    let affiliateLinkBuilder: AffiliateLinkBuilder
    let analytics: any AnalyticsEvent

    init() {
        let config = AppConfig.load()
        self.config = config
        self.cacheStore = CacheStore()
        self.entitlementManager = EntitlementManager()
        self.locationService = LocationService()
        self.affiliateLinkBuilder = AffiliateLinkBuilder(configSource: NoopAffiliateConfigSource())
        self.analytics = NoopAnalytics()

        if config.isSupabaseConfigured,
           let url = config.supabaseURL,
           let anonKey = config.supabaseAnonKey {
            let supabase = SupabaseService(supabaseURL: url, anonKey: anonKey)
            self.supabaseService = supabase
        } else {
            self.supabaseService = nil
        }

        self.storePricingService = MockStorePricingService(affiliateLinkBuilder: affiliateLinkBuilder)
        self.repairAdvisorService = RepairAdvisorService(
            supabaseService: self.supabaseService,
            cacheStore: self.cacheStore,
            forceMock: config.isMockAIEnabled
        )
    }
}
