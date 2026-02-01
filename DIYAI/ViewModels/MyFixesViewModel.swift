import Foundation

@MainActor
final class MyFixesViewModel: ObservableObject {
    @Published var summaries: [RepairJobSummary] = []
    @Published var isLoading: Bool = false
    @Published var appError: AppError?

    private let supabaseService: SupabaseService?
    private let cacheStore: CacheStore

    init(supabaseService: SupabaseService?, cacheStore: CacheStore) {
        self.supabaseService = supabaseService
        self.cacheStore = cacheStore
    }

    func load() {
        appError = nil
        isLoading = true
        let cached = cacheStore.load()

        Task {
            if let supabaseService {
                do {
                    let jobs = try await supabaseService.fetchRepairJobs()
                    var summaries: [RepairJobSummary] = []
                    for job in jobs {
                        let cachedTitle = cached.first(where: { $0.id == job.id })?.summary.title
                        var summary = RepairJobSummary(
                            id: job.id,
                            title: cachedTitle ?? job.category.capitalized,
                            createdAt: job.createdAt,
                            status: job.status,
                            category: job.category,
                            imagePath: job.imagePath,
                            thumbPath: job.thumbPath,
                            thumbURL: nil
                        )
                        summary.thumbURL = try? await supabaseService.createSignedURL(path: job.thumbPath, expiresIn: 600)
                        summaries.append(summary)
                    }
                    await MainActor.run {
                        self.summaries = summaries
                        self.isLoading = false
                    }
                } catch {
                    await MainActor.run {
                        self.appError = AppErrorMapper.map(error)
                        self.summaries = cached.map { $0.summary }
                        self.isLoading = false
                    }
                }
            } else {
                await MainActor.run {
                    self.summaries = cached.map { $0.summary }
                    self.isLoading = false
                }
            }
        }
    }

    func diagnosis(for jobId: UUID) async -> DiagnosisResult? {
        if let cached = cacheStore.load().first(where: { $0.id == jobId }) {
            return cached.diagnosis
        }
        if let supabaseService {
            return try? await supabaseService.fetchDiagnosisResult(jobId: jobId)
        }
        return nil
    }

    func delete(summary: RepairJobSummary) {
        cacheStore.remove(jobId: summary.id)
        Task {
            if let supabaseService {
                try? await supabaseService.deleteJob(jobId: summary.id, imagePath: summary.imagePath, thumbPath: summary.thumbPath)
            }
            await MainActor.run {
                self.summaries.removeAll { $0.id == summary.id }
            }
        }
    }
}
