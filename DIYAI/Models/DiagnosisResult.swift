import Foundation

struct DiagnosisResult: Identifiable, Codable, Equatable {
    var id: UUID { jobId }
    let jobId: UUID
    let issueTitle: String
    let confidence: Int
    let difficulty: String
    let estimatedMinutes: Int
    let highLevelOverview: [String]
    let tools: [ToolItem]
    let parts: [PartItem]
    let steps: [RepairStep]
    let safetyChecklist: [String]
    let commonMistakes: [String]
    let verifyBeforeBuy: [String]

    enum CodingKeys: String, CodingKey {
        case jobId = "job_id"
        case issueTitle = "issue_title"
        case confidence
        case difficulty
        case estimatedMinutes = "estimated_minutes"
        case highLevelOverview = "high_level_overview"
        case tools
        case parts
        case steps
        case safetyChecklist = "safety_checklist"
        case commonMistakes = "common_mistakes"
        case verifyBeforeBuy = "verify_before_buy"
    }
}

struct ToolItem: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let quantity: Int
    let mustHave: Bool

    init(id: UUID = UUID(), name: String, quantity: Int, mustHave: Bool) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.mustHave = mustHave
    }

    enum CodingKeys: String, CodingKey {
        case id, name, quantity, mustHave
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = (try? container.decode(UUID.self, forKey: .id)) ?? UUID()
        self.name = try container.decode(String.self, forKey: .name)
        self.quantity = try container.decode(Int.self, forKey: .quantity)
        self.mustHave = try container.decode(Bool.self, forKey: .mustHave)
    }
}

struct PartItem: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let variants: [String]
    let notes: String

    init(id: UUID = UUID(), name: String, variants: [String], notes: String) {
        self.id = id
        self.name = name
        self.variants = variants
        self.notes = notes
    }

    enum CodingKeys: String, CodingKey {
        case id, name, variants, notes
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = (try? container.decode(UUID.self, forKey: .id)) ?? UUID()
        self.name = try container.decode(String.self, forKey: .name)
        self.variants = try container.decode([String].self, forKey: .variants)
        self.notes = try container.decode(String.self, forKey: .notes)
    }
}

struct RepairStep: Identifiable, Codable, Equatable {
    let id: UUID
    let order: Int
    let title: String
    let detail: String

    init(id: UUID = UUID(), order: Int, title: String, detail: String) {
        self.id = id
        self.order = order
        self.title = title
        self.detail = detail
    }

    enum CodingKeys: String, CodingKey {
        case id, order, title, detail
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = (try? container.decode(UUID.self, forKey: .id)) ?? UUID()
        self.order = try container.decode(Int.self, forKey: .order)
        self.title = try container.decode(String.self, forKey: .title)
        self.detail = try container.decode(String.self, forKey: .detail)
    }
}
