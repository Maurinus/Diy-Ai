import Foundation

struct RepairJob: Identifiable, Codable, Equatable {
    let id: UUID
    let userId: UUID
    let createdAt: Date
    let category: String
    let note: String?
    let imagePath: String
    let thumbPath: String
    var status: String
    var errorMessage: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case createdAt = "created_at"
        case category
        case note
        case imagePath = "image_path"
        case thumbPath = "thumb_path"
        case status
        case errorMessage = "error_message"
    }
}

struct RepairJobSummary: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let createdAt: Date
    let status: String
    let category: String
    let imagePath: String
    let thumbPath: String
    var thumbURL: URL?
}
