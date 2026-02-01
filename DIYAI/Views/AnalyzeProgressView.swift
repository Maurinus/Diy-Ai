import SwiftUI

struct AnalyzeProgressView: View {
    let stage: AnalysisStage

    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
            VStack(spacing: AppSpacing.m) {
                VStack(spacing: AppSpacing.s) {
                    Text("Analyzing")
                        .font(.appHeadline)
                    Text("This usually takes under a minute.")
                        .font(.appCaption)
                        .foregroundColor(AppColors.textSecondary)
                }

                VStack(alignment: .leading, spacing: AppSpacing.s) {
                    ProgressRow(title: "Preparing photo", status: status(for: 0))
                    ProgressRow(title: "Uploading", status: status(for: 1))
                    ProgressRow(title: "Analyzing", status: status(for: 2))
                    ProgressRow(title: "Building your plan", status: status(for: 3))
                }
                .padding(.horizontal, AppSpacing.l)

                HStack(spacing: AppSpacing.s) {
                    SkeletonRow()
                    SkeletonRow()
                }
                .padding(.horizontal, AppSpacing.l)
            }
            .padding(AppSpacing.l)
            .background(AppColors.surface)
            .cornerRadius(AppCornerRadius.l)
            .shadow(radius: 30)
        }
    }

    private func status(for index: Int) -> ProgressRow.Status {
        if stage == .done { return .done }
        if stage.progressIndex > index { return .done }
        if stage.progressIndex == index { return .active }
        return .pending
    }
}

struct ProgressRow: View {
    enum Status {
        case pending
        case active
        case done
    }

    let title: String
    let status: Status

    var body: some View {
        HStack {
            switch status {
            case .done:
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(AppColors.accent)
            case .active:
                PulseDot()
            case .pending:
                Image(systemName: "circle")
                    .foregroundColor(AppColors.textSecondary)
            }
            Text(title)
                .font(.appBody)
                .foregroundColor(AppColors.textPrimary)
        }
    }
}

struct PulseDot: View {
    @State private var pulse: Bool = false

    var body: some View {
        Circle()
            .fill(AppColors.accent)
            .frame(width: 10, height: 10)
            .overlay(
                Circle()
                    .stroke(AppColors.accent.opacity(0.6), lineWidth: 6)
                    .scaleEffect(pulse ? 1.3 : 0.7)
                    .opacity(pulse ? 0 : 1)
            )
            .onAppear {
                withAnimation(.easeOut(duration: 1.2).repeatForever(autoreverses: false)) {
                    pulse = true
                }
            }
    }
}
