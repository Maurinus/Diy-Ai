import Foundation
import UIKit

struct RepairAnalysisOutput {
    let job: RepairJob
    let summary: RepairJobSummary
    let diagnosis: DiagnosisResult
}

final class RepairAdvisorService {
    private let supabaseService: SupabaseService?
    private let cacheStore: CacheStore
    private let mockAI = MockAIService()
    private let forceMock: Bool

    init(supabaseService: SupabaseService?, cacheStore: CacheStore, forceMock: Bool = false) {
        self.supabaseService = supabaseService
        self.cacheStore = cacheStore
        self.forceMock = forceMock
    }

    func analyze(
        image: UIImage,
        category: RepairCategory,
        note: String?,
        progress: @escaping (AnalysisStage) -> Void
    ) async throws -> RepairAnalysisOutput {
        await MainActor.run { progress(.preparing) }

        let (imageData, thumbData) = try await Task.detached(priority: .userInitiated) {
            guard let imageData = ImagePipeline.compressImage(image) else {
                throw AppError.storage
            }
            let thumbImage = ImagePipeline.thumbnail(from: image)
            guard let thumbData = ImagePipeline.compressImage(thumbImage, quality: 0.7) else {
                throw AppError.storage
            }
            return (imageData, thumbData)
        }.value

        let jobId = UUID()
        let createdAt = Date()

        if forceMock || supabaseService == nil {
            await MainActor.run { progress(.analyzing) }
            guard let response = mockAI.randomFixture() else {
                throw AppError.unknown("Demo data is temporarily unavailable.")
            }
            await MainActor.run { progress(.building) }
            let diagnosis = DiagnosisResult(
                jobId: jobId,
                issueTitle: response.issueTitle,
                confidence: response.confidence,
                difficulty: response.difficulty,
                estimatedMinutes: response.estimatedMinutes,
                highLevelOverview: response.highLevelOverview,
                tools: response.tools,
                parts: response.parts,
                steps: response.steps,
                safetyChecklist: response.safetyChecklist,
                commonMistakes: response.commonMistakes,
                verifyBeforeBuy: response.verifyBeforeBuy
            )
            let job = RepairJob(
                id: jobId,
                userId: UUID(),
                createdAt: createdAt,
                category: category.rawValue,
                note: note,
                imagePath: "",
                thumbPath: "",
                status: "done",
                errorMessage: nil
            )
            let summary = RepairJobSummary(
                id: jobId,
                title: diagnosis.issueTitle,
                createdAt: createdAt,
                status: "done",
                category: category.rawValue,
                imagePath: "",
                thumbPath: "",
                thumbURL: nil
            )
            let cached = CachedRepair(summary: summary, diagnosis: diagnosis)
            cacheStore.upsert(cached)
            return RepairAnalysisOutput(job: job, summary: summary, diagnosis: diagnosis)
        }

        guard let supabaseService, let userId = supabaseService.currentUserId else {
            throw AppError.auth
        }

        let imagePath = "\(userId.uuidString)/\(jobId.uuidString)/image.jpg"
        let thumbPath = "\(userId.uuidString)/\(jobId.uuidString)/thumb.jpg"

        await MainActor.run { progress(.uploading) }
        try await supabaseService.uploadImage(data: imageData, path: imagePath)
        try await supabaseService.uploadImage(data: thumbData, path: thumbPath)

        let job = RepairJob(
            id: jobId,
            userId: userId,
            createdAt: createdAt,
            category: category.rawValue,
            note: note,
            imagePath: imagePath,
            thumbPath: thumbPath,
            status: "uploaded",
            errorMessage: nil
        )

        try await supabaseService.createRepairJob(job: job)

        await MainActor.run { progress(.analyzing) }
        let signedURL = try await supabaseService.createSignedURL(path: imagePath, expiresIn: 600)
        let request = AnalyzePhotoRequest(
            job_id: jobId,
            category: category.rawValue,
            note: note,
            image_url: signedURL.absoluteString
        )
        do {
            let response = try await supabaseService.invokeAnalyzePhoto(request: request)
            await MainActor.run { progress(.building) }
            let diagnosis = DiagnosisResult(
                jobId: jobId,
                issueTitle: response.issueTitle,
                confidence: response.confidence,
                difficulty: response.difficulty,
                estimatedMinutes: response.estimatedMinutes,
                highLevelOverview: response.highLevelOverview,
                tools: response.tools,
                parts: response.parts,
                steps: response.steps,
                safetyChecklist: response.safetyChecklist,
                commonMistakes: response.commonMistakes,
                verifyBeforeBuy: response.verifyBeforeBuy
            )
            try await supabaseService.updateRepairJobStatus(jobId: jobId, status: "done")
            let summary = RepairJobSummary(
                id: jobId,
                title: diagnosis.issueTitle,
                createdAt: createdAt,
                status: "done",
                category: category.rawValue,
                imagePath: imagePath,
                thumbPath: thumbPath,
                thumbURL: nil
            )
            cacheStore.upsert(CachedRepair(summary: summary, diagnosis: diagnosis))
            return RepairAnalysisOutput(job: job, summary: summary, diagnosis: diagnosis)
        } catch {
            try? await supabaseService.updateRepairJobStatus(jobId: jobId, status: "error", errorMessage: error.localizedDescription)
            if error.localizedDescription.lowercased().contains("daily limit") || error.localizedDescription.contains("429") {
                throw AppError.rateLimited
            }
            throw error
        }
    }

    func loadCachedRepairs() -> [CachedRepair] {
        cacheStore.load()
    }

    func clearCache() {
        cacheStore.clear()
    }

    func demoRepair() -> CachedRepair? {
        guard let response = mockAI.randomFixture() else { return nil }
        let jobId = UUID()
        let createdAt = Date()
        let diagnosis = DiagnosisResult(
            jobId: jobId,
            issueTitle: response.issueTitle,
            confidence: response.confidence,
            difficulty: response.difficulty,
            estimatedMinutes: response.estimatedMinutes,
            highLevelOverview: response.highLevelOverview,
            tools: response.tools,
            parts: response.parts,
            steps: response.steps,
            safetyChecklist: response.safetyChecklist,
            commonMistakes: response.commonMistakes,
            verifyBeforeBuy: response.verifyBeforeBuy
        )
        let summary = RepairJobSummary(
            id: jobId,
            title: diagnosis.issueTitle,
            createdAt: createdAt,
            status: "done",
            category: RepairCategory.other.rawValue,
            imagePath: "",
            thumbPath: "",
            thumbURL: nil
        )
        let cached = CachedRepair(summary: summary, diagnosis: diagnosis)
        cacheStore.upsert(cached)
        return cached
    }
}
