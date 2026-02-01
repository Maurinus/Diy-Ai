import SwiftUI

struct SkeletonRow: View {
    var body: some View {
        RoundedRectangle(cornerRadius: AppCornerRadius.s)
            .fill(AppColors.surfaceElevated)
            .frame(height: 18)
            .shimmering()
    }
}

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = -1

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [Color.clear, AppColors.accent.opacity(0.18), Color.clear]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .rotationEffect(.degrees(20))
                .offset(x: phase * 200)
                .blendMode(.plusLighter)
            )
            .onAppear {
                withAnimation(.linear(duration: 1.4).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

extension View {
    func shimmering() -> some View {
        modifier(ShimmerModifier())
    }
}
