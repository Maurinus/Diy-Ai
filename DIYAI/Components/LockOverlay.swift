import SwiftUI

struct LockOverlay: View {
    let title: String
    let subtitle: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppCornerRadius.m)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: AppCornerRadius.m)
                        .stroke(AppColors.border.opacity(0.3), lineWidth: 1)
                )
            VStack(spacing: AppSpacing.s) {
                ZStack {
                    Circle()
                        .fill(AppColors.accentSoft)
                        .frame(width: 52, height: 52)
                    Image(systemName: "lock.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(AppColors.accent)
                }
                Text(title)
                    .font(.appHeadline)
                    .foregroundColor(AppColors.textPrimary)
                Text(subtitle)
                    .font(.appBody)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(AppSpacing.l)
        }
    }
}
