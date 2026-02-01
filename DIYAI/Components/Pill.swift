import SwiftUI

struct Pill: View {
    let text: String
    let color: Color
    let textColor: Color

    init(_ text: String, color: Color = AppColors.surfaceElevated, textColor: Color = AppColors.textPrimary) {
        self.text = text
        self.color = color
        self.textColor = textColor
    }

    var body: some View {
        Text(text)
            .font(.appCaption)
            .foregroundColor(textColor)
            .padding(.horizontal, AppSpacing.s)
            .padding(.vertical, AppSpacing.xxs)
            .background(color)
            .cornerRadius(AppCornerRadius.s)
    }
}

struct Chip: View {
    let title: String
    var isSelected: Bool = false
    var systemImage: String? = nil

    var body: some View {
        HStack(spacing: AppSpacing.xs) {
            if let systemImage {
                Image(systemName: systemImage)
            }
            Text(title)
                .font(.appCaption)
        }
        .foregroundColor(isSelected ? .white : AppColors.textPrimary)
        .padding(.horizontal, AppSpacing.s)
        .padding(.vertical, AppSpacing.xs)
        .background(isSelected ? AppColors.accent : AppColors.surfaceElevated)
        .overlay(
            RoundedRectangle(cornerRadius: AppCornerRadius.s)
                .stroke(AppColors.border.opacity(isSelected ? 0 : 0.6), lineWidth: 1)
        )
        .cornerRadius(AppCornerRadius.s)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}
