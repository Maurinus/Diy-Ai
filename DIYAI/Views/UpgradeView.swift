import SwiftUI

struct UpgradeView: View {
    let onDismiss: () -> Void
    let onUpgrade: () -> Void
    let onManage: () -> Void

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            VStack(spacing: AppSpacing.l) {
                Spacer()
                VStack(spacing: AppSpacing.s) {
                    ZStack {
                        Circle()
                            .fill(AppColors.accentSoft)
                            .frame(width: 84, height: 84)
                        Image(systemName: "sparkles")
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundColor(AppColors.accent)
                    }
                    Text("Go Pro")
                        .font(.appTitle)
                    Text("More daily fixes, full step-by-step plans, and confidence checks.")
                        .font(.appBody)
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                }

                Card {
                    VStack(alignment: .leading, spacing: AppSpacing.s) {
                        UpgradeRow(text: "50 analyses per day")
                        UpgradeRow(text: "Full step-by-step instructions")
                        UpgradeRow(text: "Common mistakes & verify-before-buy")
                        UpgradeRow(text: "Priority analysis speed")
                    }
                }

                VStack(spacing: AppSpacing.s) {
                    PrimaryButton(title: "Upgrade to Pro", systemImage: "crown.fill") {
                        onUpgrade()
                    }
                    SecondaryButton(title: "Manage in Settings") {
                        onManage()
                    }
                }

                Button("Not now") {
                    onDismiss()
                }
                .font(.appCaption)
                .foregroundColor(AppColors.textSecondary)
                Spacer()
            }
            .padding(AppSpacing.l)
        }
    }
}

private struct UpgradeRow: View {
    let text: String

    var body: some View {
        HStack(spacing: AppSpacing.s) {
            Image(systemName: "checkmark.seal.fill")
                .foregroundColor(AppColors.accent)
            Text(text)
                .font(.appBody)
            Spacer()
        }
    }
}
