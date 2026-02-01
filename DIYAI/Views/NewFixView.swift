import SwiftUI
import PhotosUI

struct NewFixView: View {
    @StateObject private var viewModel: NewFixViewModel
    @EnvironmentObject private var container: AppContainer
    @EnvironmentObject private var session: SessionManager
    @EnvironmentObject private var entitlementManager: EntitlementManager
    @State private var showCamera = false
    @State private var selectedItem: PhotosPickerItem?
    @State private var showResult = false
    @State private var showCameraUnavailable = false
    @State private var showPaywall = false
    @State private var showSettings = false
    @State private var showUpgradeStub = false

    init(repairAdvisorService: RepairAdvisorService) {
        _viewModel = StateObject(wrappedValue: NewFixViewModel(repairAdvisorService: repairAdvisorService))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.l) {
                Text("New Fix")
                    .font(.appTitle)

                photoSection

                Card {
                    VStack(alignment: .leading, spacing: AppSpacing.s) {
                        SectionHeader(title: "Category", subtitle: "Pick the closest match")
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: AppSpacing.s) {
                                ForEach(RepairCategory.allCases) { category in
                                    Button {
                                        viewModel.category = category
                                    } label: {
                                        Chip(title: category.displayName, isSelected: viewModel.category == category)
                                    }
                                }
                            }
                            .padding(.vertical, AppSpacing.xs)
                        }
                    }
                }

                Card {
                    VStack(alignment: .leading, spacing: AppSpacing.s) {
                        SectionHeader(title: "What's happening?", subtitle: "Optional note to help the diagnosis")
                        TextField("Describe the issue...", text: $viewModel.note, axis: .vertical)
                            .lineLimit(3, reservesSpace: true)
                            .padding(AppSpacing.s)
                            .background(AppColors.surfaceElevated)
                            .cornerRadius(AppCornerRadius.s)
                    }
                }

                PrimaryButton(title: "Analyze", systemImage: "sparkles") {
                    viewModel.analyze()
                }
                .disabled(viewModel.selectedImage == nil)
                .opacity(viewModel.selectedImage == nil ? 0.6 : 1)

                if let error = viewModel.appError, !error.isRateLimited {
                    ErrorBanner(title: error.title, message: error.message, actionTitle: error.actionTitle) {
                        viewModel.analyze()
                    }
                }
            }
            .padding(AppSpacing.l)
        }
        .background(AppColors.background)
        .sheet(isPresented: $showCamera) {
            ImagePicker(image: $viewModel.selectedImage, sourceType: .camera)
        }
        .alert("Camera not available", isPresented: $showCameraUnavailable) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Camera access is not available on this device or simulator.")
        }
        .onChange(of: selectedItem) { _, newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    await MainActor.run {
                        viewModel.selectedImage = image
                    }
                }
            }
        }
        .overlay {
            if viewModel.stage.isProcessing {
                AnalyzeProgressView(stage: viewModel.stage)
            }
        }
        .onChange(of: viewModel.stage) { _, stage in
            if stage == .done, viewModel.result != nil {
                showResult = true
            }
        }
        .onChange(of: viewModel.appError) { _, error in
            if error?.isRateLimited == true {
                showPaywall = true
            }
        }
        .navigationDestination(isPresented: $showResult) {
            if let result = viewModel.result, let summary = viewModel.summary {
                ResultView(diagnosis: result, summary: summary)
            }
        }
        .navigationDestination(isPresented: $showSettings) {
            SettingsView(repairAdvisorService: container.repairAdvisorService, sessionManager: session, entitlementManager: entitlementManager)
        }
        .sheet(isPresented: $showPaywall) {
            UpgradeView {
                showPaywall = false
            } onUpgrade: {
                showUpgradeStub = true
            } onManage: {
                showPaywall = false
                showSettings = true
            }
        }
        .alert("Upgrade coming soon", isPresented: $showUpgradeStub) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("StoreKit purchase flow will be added next.")
        }
    }

    private var photoSection: some View {
        Card {
            VStack(alignment: .leading, spacing: AppSpacing.m) {
                SectionHeader(title: "Photo", subtitle: "Add a clear shot of the issue")
                if let image = viewModel.selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(AppCornerRadius.m)
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: AppCornerRadius.m)
                            .fill(AppColors.surfaceElevated)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppCornerRadius.m)
                                    .stroke(AppColors.border.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [6]))
                            )
                        VStack(spacing: AppSpacing.s) {
                            Image(systemName: "camera.viewfinder")
                                .font(.system(size: 36, weight: .semibold))
                                .foregroundColor(AppColors.textSecondary)
                            Text("Add a photo to start")
                                .font(.appBody)
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 180)
                }

                HStack(spacing: AppSpacing.s) {
                    SecondaryButton(title: "Take Photo", systemImage: "camera") {
                        if UIImagePickerController.isSourceTypeAvailable(.camera) {
                            showCamera = true
                        } else {
                            showCameraUnavailable = true
                        }
                    }

                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        HStack(spacing: AppSpacing.xs) {
                            Image(systemName: "photo.on.rectangle")
                            Text("Choose from Library")
                        }
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }
            }
        }
    }
}
