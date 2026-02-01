import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var container: AppContainer
    @EnvironmentObject private var session: SessionManager
    @EnvironmentObject private var entitlementManager: EntitlementManager

    @State private var showDemoResult = false
    @State private var demoRepair: CachedRepair?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.l) {
                    hero

                    VStack(spacing: AppSpacing.s) {
                        NavigationLink(destination: NewFixView(repairAdvisorService: container.repairAdvisorService)) {
                            Text("Start Fix")
                        }
                        .buttonStyle(PrimaryButtonStyle())

                        NavigationLink(destination: MyFixesView(supabaseService: container.supabaseService, cacheStore: container.cacheStore)) {
                            Text("My Fixes")
                        }
                        .buttonStyle(SecondaryButtonStyle())
                    }

                    Card {
                        VStack(alignment: .leading, spacing: AppSpacing.m) {
                            SectionHeader(title: "Examples", subtitle: "Preview how DIY AI breaks down a fix.")

                            VStack(alignment: .leading, spacing: AppSpacing.s) {
                                ExampleRow(title: "Loose cabinet hinge", subtitle: "Door / Easy")
                                ExampleRow(title: "Leaky faucet handle", subtitle: "Plumbing / Medium")
                                ExampleRow(title: "Sticking drawer", subtitle: "Furniture / Easy")
                            }

                            SecondaryButton(title: "Try a demo fix") {
                                demoRepair = container.repairAdvisorService.demoRepair()
                                showDemoResult = demoRepair != nil
                            }
                        }
                    }

                    if session.isDemoMode {
                        Text("Demo mode: connect Supabase for cloud sync and Pro entitlements.")
                            .font(.appCaption)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                .padding(AppSpacing.l)
            }
            .background(AppColors.background)
            .navigationTitle("DIY AI")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView(repairAdvisorService: container.repairAdvisorService, sessionManager: session, entitlementManager: entitlementManager)) {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .navigationDestination(isPresented: $showDemoResult) {
                if let demoRepair {
                    ResultView(diagnosis: demoRepair.diagnosis, summary: demoRepair.summary)
                }
            }
        }
    }

    private var hero: some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppCornerRadius.l)
                .fill(
                    LinearGradient(
                        colors: [AppColors.accent.opacity(0.95), AppColors.accent.opacity(0.75)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: AppColors.accent.opacity(0.3), radius: 20, x: 0, y: 12)

            VStack(alignment: .leading, spacing: AppSpacing.s) {
                Text("DIY AI")
                    .font(.appLargeTitle)
                    .foregroundColor(.white)
                Text("Shazam for fixing things")
                    .font(.appBody)
                    .foregroundColor(.white.opacity(0.85))
                HStack(spacing: AppSpacing.s) {
                    Pill("Fast diagnosis", color: .white.opacity(0.2), textColor: .white)
                    Pill("Repair plan", color: .white.opacity(0.2), textColor: .white)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(AppSpacing.l)
        }
        .frame(height: 180)
    }
}

struct ExampleRow: View {
    let title: String
    let subtitle: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.appBody)
                Text(subtitle)
                    .font(.appCaption)
                    .foregroundColor(AppColors.textSecondary)
            }
            Spacer()
            Image(systemName: "sparkles")
                .foregroundColor(AppColors.accent)
        }
        .padding(.vertical, 4)
    }
}
