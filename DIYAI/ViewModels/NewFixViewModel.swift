import Foundation
import UIKit

@MainActor
final class NewFixViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var category: RepairCategory = .door
    @Published var note: String = ""
    @Published var stage: AnalysisStage = .idle
    @Published var result: DiagnosisResult?
    @Published var summary: RepairJobSummary?
    @Published var appError: AppError?

    private let repairAdvisorService: RepairAdvisorService

    init(repairAdvisorService: RepairAdvisorService) {
        self.repairAdvisorService = repairAdvisorService
    }

    func analyze() {
        guard let image = selectedImage else {
            appError = .unknown("Please choose a photo first.")
            return
        }
        appError = nil
        stage = .preparing

        Task {
            do {
                let output = try await repairAdvisorService.analyze(
                    image: image,
                    category: category,
                    note: note.isEmpty ? nil : note
                ) { [weak self] stage in
                    DispatchQueue.main.async {
                        self?.stage = stage
                    }
                }
                await MainActor.run {
                    self.result = output.diagnosis
                    self.summary = output.summary
                    self.stage = .done
                }
            } catch {
                await MainActor.run {
                    self.stage = .failed(error.localizedDescription)
                    self.appError = AppErrorMapper.map(error)
                }
            }
        }
    }

    func reset() {
        selectedImage = nil
        note = ""
        stage = .idle
        result = nil
        summary = nil
        appError = nil
    }
}
