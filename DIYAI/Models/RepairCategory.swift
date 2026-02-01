import Foundation

enum RepairCategory: String, CaseIterable, Identifiable, Codable {
    case door
    case plumbing
    case electrical
    case furniture
    case other

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .door: return "Door"
        case .plumbing: return "Plumbing"
        case .electrical: return "Electrical"
        case .furniture: return "Furniture"
        case .other: return "Other"
        }
    }
}
