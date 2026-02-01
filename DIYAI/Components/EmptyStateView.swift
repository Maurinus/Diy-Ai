import SwiftUI

struct EmptyStateView: View {
    let title: String
    let subtitle: String
    var systemImage: String = "tray"
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: AppSpacing.s) {
            Image(systemName: systemImage)
                .font(.system(size: 44, weight: .semibold))
                .foregroundColor(AppColors.textSecondary)
            Text(title)
                .font(.appHeadline)
                .foregroundColor(AppColors.textPrimary)
            Text(subtitle)
                .font(.appBody)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)

            if let actionTitle, let action {
                SecondaryButton(title: actionTitle, action: action)
                    .frame(maxWidth: 220)
                    .padding(.top, AppSpacing.xs)
            }
        }
        .padding(AppSpacing.xl)
        .background(AppColors.surface)
        .overlay(
            RoundedRectangle(cornerRadius: AppCornerRadius.l)
                .stroke(AppColors.border.opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(AppCornerRadius.l)
        .shadow(color: AppColors.shadow.opacity(0.6), radius: 16, x: 0, y: 8)
    }
}
