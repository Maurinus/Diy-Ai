import SwiftUI

struct MyFixesView: View {
    @StateObject private var viewModel: MyFixesViewModel
    @State private var selectedSummary: RepairJobSummary?
    @State private var selectedDiagnosis: DiagnosisResult?
    @State private var showResult = false

    init(supabaseService: SupabaseService?, cacheStore: CacheStore) {
        _viewModel = StateObject(wrappedValue: MyFixesViewModel(supabaseService: supabaseService, cacheStore: cacheStore))
    }

    var body: some View {
        VStack {
            if viewModel.isLoading {
                VStack(spacing: AppSpacing.m) {
                    SkeletonRow()
                    SkeletonRow()
                    SkeletonRow()
                }
                .padding(AppSpacing.l)
            } else if viewModel.summaries.isEmpty {
                if let error = viewModel.appError {
                    ErrorBanner(title: error.title, message: error.message, actionTitle: error.actionTitle) {
                        viewModel.load()
                    }
                    .padding(AppSpacing.l)
                } else {
                    EmptyStateView(title: "No fixes yet", subtitle: "Start a new fix to see it here.")
                }
            } else {
                List {
                    if let error = viewModel.appError {
                        ErrorBanner(title: error.title, message: error.message, actionTitle: error.actionTitle) {
                            viewModel.load()
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                    ForEach(viewModel.summaries) { summary in
                        Card {
                            Button {
                                Task {
                                    selectedSummary = summary
                                    selectedDiagnosis = await viewModel.diagnosis(for: summary.id)
                                    showResult = selectedDiagnosis != nil
                                }
                            } label: {
                                HStack(spacing: AppSpacing.m) {
                                    ThumbnailView(url: summary.thumbURL)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(summary.title)
                                            .font(.appBody)
                                            .foregroundColor(AppColors.textPrimary)
                                        Text(summary.createdAt.formatted(date: .abbreviated, time: .shortened))
                                            .font(.appCaption)
                                            .foregroundColor(AppColors.textSecondary)
                                    }
                                    Spacer()
                                    Pill(summary.status.capitalized, color: AppColors.surfaceElevated)
                                }
                            }
                            .buttonStyle(.plain)
                            .swipeActions {
                                Button(role: .destructive) {
                                    viewModel.delete(summary: summary)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle("My Fixes")
        .onAppear {
            viewModel.load()
        }
        .navigationDestination(isPresented: $showResult) {
            if let diagnosis = selectedDiagnosis, let summary = selectedSummary {
                ResultView(diagnosis: diagnosis, summary: summary)
            }
        }
    }
}

struct ThumbnailView: View {
    let url: URL?

    var body: some View {
        if let url {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                case .failure:
                    placeholder
                case .empty:
                    placeholder
                @unknown default:
                    placeholder
                }
            }
            .frame(width: 56, height: 56)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        } else {
            placeholder
                .frame(width: 56, height: 56)
        }
    }

    private var placeholder: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(AppColors.surfaceElevated)
            .overlay(Image(systemName: "photo").foregroundColor(AppColors.textSecondary))
    }
}
