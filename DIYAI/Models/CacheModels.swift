import Foundation

struct CachedRepair: Identifiable, Codable, Equatable {
    let id: UUID
    let summary: RepairJobSummary
    let diagnosis: DiagnosisResult

    init(summary: RepairJobSummary, diagnosis: DiagnosisResult) {
        self.id = summary.id
        self.summary = summary
        self.diagnosis = diagnosis
    }
}
