import SwiftUI
import UIKit

enum AppColors {
    static let accent = Color(red: 0.12, green: 0.48, blue: 0.93)
    static let accentSoft = Color(red: 0.12, green: 0.48, blue: 0.93, opacity: 0.12)
    static let background = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.05, green: 0.06, blue: 0.08, alpha: 1)
            : UIColor(red: 0.96, green: 0.96, blue: 0.97, alpha: 1)
    })
    static let surface = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.12, green: 0.13, blue: 0.16, alpha: 1)
            : UIColor.white
    })
    static let surfaceElevated = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.16, green: 0.17, blue: 0.20, alpha: 1)
            : UIColor(red: 0.99, green: 0.99, blue: 1.00, alpha: 1)
    })
    static let textPrimary = Color(UIColor.label)
    static let textSecondary = Color(UIColor.secondaryLabel)
    static let border = Color(UIColor.separator)
    static let shadow = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor.black.withAlphaComponent(0.4)
            : UIColor.black.withAlphaComponent(0.12)
    })
    static let success = Color(red: 0.18, green: 0.72, blue: 0.36)
    static let warning = Color(red: 0.96, green: 0.64, blue: 0.23)
}

enum AppSpacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let s: CGFloat = 12
    static let m: CGFloat = 16
    static let l: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 40
    static let xxxl: CGFloat = 56
}

enum AppCornerRadius {
    static let xs: CGFloat = 8
    static let s: CGFloat = 12
    static let m: CGFloat = 16
    static let l: CGFloat = 22
    static let xl: CGFloat = 28
}

extension Font {
    static let appLargeTitle = Font.system(size: 34, weight: .bold, design: .default)
    static let appTitle = Font.system(size: 28, weight: .bold, design: .default)
    static let appHeadline = Font.system(size: 20, weight: .semibold, design: .default)
    static let appSubheadline = Font.system(size: 17, weight: .medium, design: .default)
    static let appBody = Font.system(size: 16, weight: .regular, design: .default)
    static let appCaption = Font.system(size: 13, weight: .medium, design: .default)
    static let appFootnote = Font.system(size: 12, weight: .regular, design: .default)
}

struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(AppSpacing.m)
            .background(AppColors.surface)
            .overlay(
                RoundedRectangle(cornerRadius: AppCornerRadius.m)
                    .stroke(AppColors.border.opacity(0.4), lineWidth: 1)
            )
            .cornerRadius(AppCornerRadius.m)
            .shadow(color: AppColors.shadow, radius: 14, x: 0, y: 6)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardModifier())
    }
}
