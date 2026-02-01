import Foundation
import Supabase

@MainActor
final class SessionManager: ObservableObject {
    enum State {
        case loading
        case signedOut
        case signedIn
        case demo
    }

    @Published private(set) var state: State = .loading
    @Published private(set) var profile: Profile?
    @Published var authErrorMessage: String?

    private let supabaseService: SupabaseService?
    private let entitlementManager: EntitlementManager

    init(supabaseService: SupabaseService?, entitlementManager: EntitlementManager) {
        self.supabaseService = supabaseService
        self.entitlementManager = entitlementManager
        Task {
            await refreshSession()
            await listenForAuthChanges()
        }
    }

    var isAuthenticated: Bool {
        if case .signedIn = state { return true }
        return false
    }

    var isDemoMode: Bool {
        if case .demo = state { return true }
        return false
    }

    func refreshSession() async {
        guard let supabaseService else {
            state = .demo
            return
        }

        if let _ = supabaseService.currentSession {
            state = .signedIn
            await loadProfile()
        } else {
            state = .signedOut
        }
    }

    func listenForAuthChanges() async {
        guard let supabaseService else { return }
        for await (event, session) in supabaseService.client.auth.authStateChanges {
            switch event {
            case .initialSession:
                state = session == nil ? .signedOut : .signedIn
            case .signedIn, .tokenRefreshed:
                state = .signedIn
                await loadProfile()
            case .signedOut:
                state = .signedOut
                profile = nil
                entitlementManager.updateFromProfile(nil)
            case .passwordRecovery, .userUpdated:
                break
            @unknown default:
                break
            }
        }
    }

    func signInWithEmail(_ email: String) async {
        authErrorMessage = nil
        guard let supabaseService else {
            authErrorMessage = "Supabase is not configured."
            return
        }
        do {
            try await supabaseService.sendMagicLink(email: email)
        } catch {
            authErrorMessage = error.localizedDescription
        }
    }

    func signInAnonymously() async {
        authErrorMessage = nil
        guard let supabaseService else {
            state = .demo
            return
        }
        do {
            _ = try await supabaseService.signInAnonymously()
            state = .signedIn
            await loadProfile()
        } catch {
            authErrorMessage = error.localizedDescription
        }
    }

    func signOut() async {
        guard let supabaseService else {
            state = .demo
            return
        }
        do {
            try await supabaseService.signOut()
            state = .signedOut
        } catch {
            authErrorMessage = error.localizedDescription
        }
    }

    func handleOpenURL(_ url: URL) async {
        guard let supabaseService else { return }
        do {
            _ = try await supabaseService.handleOpenURL(url)
            state = .signedIn
            await loadProfile()
        } catch {
            authErrorMessage = error.localizedDescription
        }
    }

    private func loadProfile() async {
        guard let supabaseService else { return }
        do {
            let profile = try await supabaseService.fetchProfile()
            self.profile = profile
            entitlementManager.updateFromProfile(profile)
        } catch {
            authErrorMessage = error.localizedDescription
        }
    }
}
