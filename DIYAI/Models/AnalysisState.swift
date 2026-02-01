import Foundation

enum AnalysisStage: Equatable {
    case idle
    case preparing
    case uploading
    case analyzing
    case building
    case done
    case failed(String)

    var isProcessing: Bool {
        switch self {
        case .preparing, .uploading, .analyzing, .building:
            return true
        default:
            return false
        }
    }

    var progressIndex: Int {
        switch self {
        case .preparing: return 0
        case .uploading: return 1
        case .analyzing: return 2
        case .building: return 3
        case .done: return 4
        case .failed: return 0
        case .idle: return 0
        }
    }
}
