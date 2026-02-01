import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.appSubheadline)
            .foregroundColor(.white)
            .padding(.vertical, AppSpacing.s)
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(
                RoundedRectangle(cornerRadius: AppCornerRadius.m)
                    .fill(AppColors.accent)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppCornerRadius.m)
                    .stroke(Color.white.opacity(configuration.isPressed ? 0.15 : 0.06), lineWidth: 1)
            )
            .shadow(color: AppColors.accent.opacity(configuration.isPressed ? 0.2 : 0.35), radius: 12, x: 0, y: 6)
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.appSubheadline)
            .foregroundColor(AppColors.textPrimary)
            .padding(.vertical, AppSpacing.s)
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(AppColors.surfaceElevated)
            .overlay(
                RoundedRectangle(cornerRadius: AppCornerRadius.m)
                    .stroke(AppColors.border.opacity(0.6), lineWidth: 1)
            )
            .cornerRadius(AppCornerRadius.m)
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
    }
}

struct PrimaryButton: View {
    let title: String
    var systemImage: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            label
        }
        .buttonStyle(PrimaryButtonStyle())
    }

    private var label: some View {
        HStack(spacing: AppSpacing.xs) {
            if let systemImage {
                Image(systemName: systemImage)
            }
            Text(title)
        }
    }
}

struct SecondaryButton: View {
    let title: String
    var systemImage: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            label
        }
        .buttonStyle(SecondaryButtonStyle())
    }

    private var label: some View {
        HStack(spacing: AppSpacing.xs) {
            if let systemImage {
                Image(systemName: systemImage)
            }
            Text(title)
        }
    }
}
