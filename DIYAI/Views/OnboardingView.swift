import SwiftUI

struct OnboardingView: View {
    let onFinish: () -> Void
    @State private var selection: Int = 0

    var body: some View {
        VStack(spacing: AppSpacing.l) {
            VStack(spacing: AppSpacing.xs) {
                Text("DIY AI")
                    .font(.appHeadline)
                    .foregroundColor(AppColors.textPrimary)
                Text("Shazam for fixing things")
                    .font(.appCaption)
                    .foregroundColor(AppColors.textSecondary)
            }
            .padding(.top, AppSpacing.xl)

            TabView(selection: $selection) {
                OnboardingSlide(
                    title: "Snap it. Fix it.",
                    subtitle: "Take a photo and get a confident diagnosis in seconds.",
                    systemImage: "camera.viewfinder"
                )
                .tag(0)
                OnboardingSlide(
                    title: "Know what to buy.",
                    subtitle: "We list the exact tools, parts, and variants you need.",
                    systemImage: "list.bullet.rectangle"
                )
                .tag(1)
                OnboardingSlide(
                    title: "Fix with confidence.",
                    subtitle: "Step-by-step guidance and safety checks, right when you need them.",
                    systemImage: "checkmark.seal"
                )
                .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            PrimaryButton(title: selection == 2 ? "Continue" : "Next") {
                if selection < 2 {
                    withAnimation(.easeInOut) {
                        selection += 1
                    }
                } else {
                    onFinish()
                }
            }
            .padding(.horizontal, AppSpacing.l)
            .padding(.bottom, AppSpacing.xl)
        }
        .background(AppColors.background)
    }
}

struct OnboardingSlide: View {
    let title: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        VStack(spacing: AppSpacing.l) {
            ZStack {
                Circle()
                    .fill(AppColors.accentSoft)
                    .frame(width: 120, height: 120)
                Image(systemName: systemImage)
                    .font(.system(size: 46, weight: .semibold))
                    .foregroundColor(AppColors.accent)
            }

            VStack(spacing: AppSpacing.s) {
                Text(title)
                    .font(.appTitle)
                    .foregroundColor(AppColors.textPrimary)
                Text(subtitle)
                    .font(.appBody)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppSpacing.l)
            }
        }
        .padding(.horizontal, AppSpacing.xl)
    }
}
