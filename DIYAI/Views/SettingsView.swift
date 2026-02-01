import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel: SettingsViewModel
    @EnvironmentObject private var session: SessionManager
    @EnvironmentObject private var entitlementManager: EntitlementManager

    init(repairAdvisorService: RepairAdvisorService, sessionManager: SessionManager, entitlementManager: EntitlementManager) {
        _viewModel = StateObject(wrappedValue: SettingsViewModel(entitlementManager: entitlementManager, repairAdvisorService: repairAdvisorService, sessionManager: sessionManager))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.l) {
                Card {
                    VStack(alignment: .leading, spacing: AppSpacing.s) {
                        SectionHeader(title: "Account")
                        if session.isAuthenticated {
                            Text("Signed in")
                                .font(.appBody)
                        } else if session.isDemoMode {
                            Text("Demo mode")
                                .font(.appBody)
                        } else {
                            Text("Signed out")
                                .font(.appBody)
                        }
                    }
                }

                Card {
                    VStack(alignment: .leading, spacing: AppSpacing.s) {
                        SectionHeader(title: "Pro status")
                        HStack(spacing: AppSpacing.s) {
                            Text(entitlementManager.isPro ? "Pro active" : "Free tier")
                                .font(.appBody)
                            Pill(entitlementManager.isPro ? "Pro" : "Free", color: entitlementManager.isPro ? AppColors.accentSoft : AppColors.surfaceElevated, textColor: entitlementManager.isPro ? AppColors.accent : AppColors.textSecondary)
                        }
                        Toggle("Pro Mode (Debug)", isOn: Binding(
                            get: { viewModel.debugProEnabled },
                            set: { viewModel.toggleDebugPro($0) }
                        ))
                        Text("Debug only. This unlocks Pro UI locally.")
                            .font(.appFootnote)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }

                Card {
                    VStack(alignment: .leading, spacing: AppSpacing.s) {
                        SectionHeader(title: "Usage")
                        if let profile = session.profile {
                            let limit = Double(entitlementManager.dailyLimit)
                            let used = Double(profile.dailyCount)
                            ProgressView(value: min(used, limit), total: limit)
                                .tint(AppColors.accent)
                            Text("\(profile.dailyCount) of \(entitlementManager.dailyLimit) analyses today")
                                .font(.appBody)
                                .foregroundColor(AppColors.textSecondary)
                        } else {
                            Text("Usage data unavailable")
                                .font(.appBody)
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                }

                VStack(spacing: AppSpacing.s) {
                    Button("Reset onboarding") {
                        viewModel.resetOnboarding()
                    }
                    .buttonStyle(SecondaryButtonStyle())

                    Button("Clear local cache") {
                        viewModel.clearCache()
                    }
                    .buttonStyle(SecondaryButtonStyle())

                    Button("Sign out") {
                        Task { await viewModel.signOut() }
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }

                if let message = viewModel.message {
                    Text(message)
                        .font(.appCaption)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            .padding(AppSpacing.l)
        }
        .background(AppColors.background)
        .navigationTitle("Settings")
    }
}
