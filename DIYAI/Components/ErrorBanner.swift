import SwiftUI

struct ErrorBanner: View {
    let title: String
    let message: String
    let actionTitle: String
    let action: () -> Void

    var body: some View {
        Card {
            HStack(alignment: .top, spacing: AppSpacing.m) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(AppColors.warning)
                    .font(.system(size: 20, weight: .semibold))
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(title)
                        .font(.appHeadline)
                    Text(message)
                        .font(.appCaption)
                        .foregroundColor(AppColors.textSecondary)
                    Button(actionTitle, action: action)
                        .buttonStyle(SecondaryButtonStyle())
                        .frame(maxWidth: 160)
                }
                Spacer()
            }
        }
    }
}
