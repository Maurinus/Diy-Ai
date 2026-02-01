import SwiftUI

struct RootView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @EnvironmentObject private var session: SessionManager

    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            if !hasSeenOnboarding {
                OnboardingView {
                    hasSeenOnboarding = true
                }
            } else {
                switch session.state {
                case .loading:
                    ProgressView("Preparing...")
                        .font(.appBody)
                case .signedOut:
                    AuthView()
                case .signedIn, .demo:
                    HomeView()
                }
            }
        }
    }
}
