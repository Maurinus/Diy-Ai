import SwiftUI

struct ResultView: View {
    enum Tab: String, CaseIterable, Identifiable {
        case overview = "Overview"
        case tools = "Tools"
        case parts = "Parts"
        case steps = "Steps"
        case safety = "Safety"

        var id: String { rawValue }
    }

    let diagnosis: DiagnosisResult
    let summary: RepairJobSummary

    @EnvironmentObject private var entitlementManager: EntitlementManager
    @EnvironmentObject private var container: AppContainer
    @State private var selectedTab: Tab = .overview

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.l) {
                header

                Picker("Tab", selection: $selectedTab) {
                    ForEach(Tab.allCases) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(.segmented)

                switch selectedTab {
                case .overview:
                    OverviewTab(diagnosis: diagnosis, isPro: entitlementManager.isPro) {
                        selectedTab = .tools
                    }
                case .tools:
                    ToolsTab(diagnosis: diagnosis, category: summary.category, service: container.storePricingService)
                case .parts:
                    PartsTab(diagnosis: diagnosis, category: summary.category, service: container.storePricingService)
                case .steps:
                    StepsTab(diagnosis: diagnosis, isPro: entitlementManager.isPro)
                case .safety:
                    SafetyTab(diagnosis: diagnosis, isPro: entitlementManager.isPro)
                }
            }
            .padding(AppSpacing.l)
        }
        .background(AppColors.background)
        .navigationTitle("Result")
    }

    private var header: some View {
        Card {
            VStack(alignment: .leading, spacing: AppSpacing.s) {
                Text(diagnosis.issueTitle)
                    .font(.appTitle)
                HStack(spacing: AppSpacing.s) {
                    Pill("Confidence \(diagnosis.confidence)%", color: AppColors.accentSoft, textColor: AppColors.accent)
                    Pill(diagnosis.difficulty, color: AppColors.surfaceElevated)
                    Pill("~\(diagnosis.estimatedMinutes) min", color: AppColors.surfaceElevated)
                }
            }
        }
    }
}

struct OverviewTab: View {
    let diagnosis: DiagnosisResult
    let isPro: Bool
    let onFindItems: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.l) {
            Card {
                VStack(alignment: .leading, spacing: AppSpacing.s) {
                    SectionHeader(title: "High-level overview", subtitle: "Free summary of the fix")
                    ForEach(diagnosis.highLevelOverview, id: \.self) { item in
                        HStack(alignment: .top) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(AppColors.accent)
                            Text(item)
                                .font(.appBody)
                        }
                    }

                    PrimaryButton(title: "Find tools & parts", systemImage: "magnifyingglass") {
                        onFindItems()
                    }
                }
            }

            ConfidenceSection(title: "Common mistakes to avoid", items: diagnosis.commonMistakes, isLocked: !isPro, icon: "exclamationmark.triangle.fill")
            ConfidenceSection(title: "Verify before you buy", items: diagnosis.verifyBeforeBuy, isLocked: !isPro, icon: "checkmark.seal.fill")
            ConfidenceSection(title: "Exact sizing checklist", items: sizingChecklist, isLocked: !isPro, icon: "ruler")
        }
    }

    private var sizingChecklist: [String] {
        diagnosis.parts.map { "Confirm dimensions and variant for \($0.name)" }
    }
}

struct ToolsTab: View {
    let diagnosis: DiagnosisResult
    let category: String
    let service: StorePricingServiceProtocol
    @State private var ownedTools: Set<UUID> = []

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.m) {
            SectionHeader(title: "Tools", subtitle: "Mark what you already own")
            ForEach(diagnosis.tools) { tool in
                Card {
                    VStack(alignment: .leading, spacing: AppSpacing.s) {
                        HStack(alignment: .top, spacing: AppSpacing.m) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(tool.name)
                                    .font(.appHeadline)
                                Text("Qty: \(tool.quantity)")
                                    .font(.appCaption)
                                    .foregroundColor(AppColors.textSecondary)
                                if tool.mustHave {
                                    Pill("Must have", color: AppColors.accentSoft, textColor: AppColors.accent)
                                }
                            }
                            Spacer()
                            Toggle("I have this", isOn: Binding(
                                get: { ownedTools.contains(tool.id) },
                                set: { newValue in
                                    if newValue { ownedTools.insert(tool.id) } else { ownedTools.remove(tool.id) }
                                }
                            ))
                            .font(.appCaption)
                        }

                        NavigationLink(destination: FindItemsView(item: CatalogItem(name: tool.name, selectedVariant: nil, category: RepairCategory(rawValue: category) ?? .other), service: service)) {
                            Text("Compare prices")
                        }
                        .buttonStyle(SecondaryButtonStyle())
                    }
                }
            }
        }
    }
}

struct PartsTab: View {
    let diagnosis: DiagnosisResult
    let category: String
    let service: StorePricingServiceProtocol
    @State private var selectedVariants: [UUID: String] = [:]

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.m) {
            SectionHeader(title: "Parts", subtitle: "Select a variant before comparing")
            ForEach(diagnosis.parts) { part in
                Card {
                    VStack(alignment: .leading, spacing: AppSpacing.s) {
                        Text(part.name)
                            .font(.appHeadline)
                        if !part.variants.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: AppSpacing.s) {
                                    ForEach(part.variants, id: \.self) { variant in
                                        Button {
                                            selectedVariants[part.id] = variant
                                        } label: {
                                            Chip(title: variant, isSelected: selectedVariants[part.id] == variant)
                                        }
                                    }
                                }
                                .padding(.vertical, AppSpacing.xs)
                            }
                        }
                        if !part.notes.isEmpty {
                            Text(part.notes)
                                .font(.appCaption)
                                .foregroundColor(AppColors.textSecondary)
                        }
                        NavigationLink(destination: FindItemsView(item: CatalogItem(name: part.name, selectedVariant: selectedVariants[part.id], category: RepairCategory(rawValue: category) ?? .other), service: service)) {
                            Text("Compare prices")
                        }
                        .buttonStyle(SecondaryButtonStyle())
                    }
                }
            }
        }
    }
}

struct StepsTab: View {
    let diagnosis: DiagnosisResult
    let isPro: Bool
    @State private var completedSteps: Set<UUID> = []

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.m) {
            ZStack {
                Card {
                    VStack(alignment: .leading, spacing: AppSpacing.s) {
                        SectionHeader(title: "Step-by-step", subtitle: isPro ? "Follow each step and check off as you go" : "Preview of the repair plan")
                        ForEach(isPro ? diagnosis.steps : Array(diagnosis.steps.prefix(2))) { step in
                            HStack(alignment: .top, spacing: AppSpacing.s) {
                                if isPro {
                                    Button {
                                        toggle(step.id)
                                    } label: {
                                        Image(systemName: completedSteps.contains(step.id) ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(AppColors.accent)
                                    }
                                }
                                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                                    Text("Step \(step.order): \(step.title)")
                                        .font(.appBody)
                                    Text(step.detail)
                                        .font(.appCaption)
                                        .foregroundColor(AppColors.textSecondary)
                                }
                            }
                            .padding(.vertical, AppSpacing.xs)
                        }
                    }
                }
                .blur(radius: isPro ? 0 : 2)

                if !isPro {
                    LockOverlay(title: "Unlock full steps", subtitle: "Go Pro for the complete repair plan and checklists.")
                        .frame(height: 200)
                }
            }
        }
    }

    private func toggle(_ id: UUID) {
        if completedSteps.contains(id) {
            completedSteps.remove(id)
        } else {
            completedSteps.insert(id)
        }
    }
}

struct SafetyTab: View {
    let diagnosis: DiagnosisResult
    let isPro: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.m) {
            Card {
                VStack(alignment: .leading, spacing: AppSpacing.s) {
                    SectionHeader(title: "Safety checklist", subtitle: "Follow these precautions")
                    ForEach(diagnosis.safetyChecklist, id: \.self) { item in
                        HStack(alignment: .top) {
                            Image(systemName: "shield.fill")
                                .foregroundColor(AppColors.warning)
                            Text(item)
                                .font(.appBody)
                        }
                    }
                }
            }

            ConfidenceSection(title: "Common mistakes", items: diagnosis.commonMistakes, isLocked: !isPro, icon: "exclamationmark.triangle.fill")
        }
    }
}

struct ConfidenceSection: View {
    let title: String
    let items: [String]
    let isLocked: Bool
    let icon: String

    var body: some View {
        ZStack {
            Card {
                VStack(alignment: .leading, spacing: AppSpacing.s) {
                    HStack(spacing: AppSpacing.s) {
                        Image(systemName: icon)
                            .foregroundColor(AppColors.accent)
                        Text(title)
                            .font(.appHeadline)
                    }
                    ForEach(items, id: \.self) { item in
                        Text("- \(item)")
                            .font(.appBody)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
            }
            if isLocked {
                LockOverlay(title: "Pro only", subtitle: "Upgrade for confidence checks and expert tips.")
            }
        }
    }
}
