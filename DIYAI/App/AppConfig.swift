import Foundation

struct AppConfig: Sendable {
    let supabaseURL: URL?
    let supabaseAnonKey: String?
    let isSupabaseConfigured: Bool
    let isMockAIEnabled: Bool

    static func load() -> AppConfig {
        guard let url = Bundle.main.url(forResource: "Config", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any] else {
            return AppConfig(supabaseURL: nil, supabaseAnonKey: nil, isSupabaseConfigured: false, isMockAIEnabled: true)
        }

        let supabaseURLString = plist["SUPABASE_URL"] as? String
        let supabaseAnonKey = plist["SUPABASE_ANON_KEY"] as? String
        let mockAI = plist["MOCK_AI_MODE"] as? Bool ?? false

        let urlValue = supabaseURLString.flatMap(URL.init(string:))
        let isConfigured = (urlValue != nil) && !(supabaseAnonKey ?? "").isEmpty

        return AppConfig(
            supabaseURL: urlValue,
            supabaseAnonKey: supabaseAnonKey,
            isSupabaseConfigured: isConfigured,
            isMockAIEnabled: mockAI || !isConfigured
        )
    }
}
