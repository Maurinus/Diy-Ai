import Foundation

struct Profile: Identifiable, Codable, Equatable {
    let id: UUID
    var createdAt: Date
    var isPro: Bool
    var dailyCount: Int
    var dailyCountDate: Date

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case isPro = "is_pro"
        case dailyCount = "daily_count"
        case dailyCountDate = "daily_count_date"
    }

    init(id: UUID, createdAt: Date, isPro: Bool, dailyCount: Int, dailyCountDate: Date) {
        self.id = id
        self.createdAt = createdAt
        self.isPro = isPro
        self.dailyCount = dailyCount
        self.dailyCountDate = dailyCountDate
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        let createdAtString = try container.decode(String.self, forKey: .createdAt)
        createdAt = Self.parseDate(createdAtString)
        isPro = try container.decodeIfPresent(Bool.self, forKey: .isPro) ?? false
        dailyCount = try container.decodeIfPresent(Int.self, forKey: .dailyCount) ?? 0
        let dailyDateString = try container.decodeIfPresent(String.self, forKey: .dailyCountDate) ?? ""
        dailyCountDate = Self.parseDate(dailyDateString)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(isPro, forKey: .isPro)
        try container.encode(dailyCount, forKey: .dailyCount)
        try container.encode(dailyCountDate, forKey: .dailyCountDate)
    }

    private static func parseDate(_ value: String) -> Date {
        let isoFormatter = ISO8601DateFormatter()
        if let date = isoFormatter.date(from: value) {
            return date
        }
        let dateOnly = DateFormatter()
        dateOnly.locale = Locale(identifier: "en_US_POSIX")
        dateOnly.dateFormat = "yyyy-MM-dd"
        if let date = dateOnly.date(from: value) {
            return date
        }
        return Date()
    }
}
