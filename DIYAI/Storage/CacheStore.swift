import Foundation

final class CacheStore {
    private let fileURL: URL
    private let maxItems: Int = 20
    private let queue = DispatchQueue(label: "CacheStoreQueue")

    init() {
        let directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
        let folder = directory?.appendingPathComponent("DIYAI", isDirectory: true)
        if let folder {
            try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        }
        self.fileURL = (folder ?? directory ?? FileManager.default.temporaryDirectory).appendingPathComponent("cache.json")
    }

    func load() -> [CachedRepair] {
        queue.sync {
            guard let data = try? Data(contentsOf: fileURL) else { return [] }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return (try? decoder.decode([CachedRepair].self, from: data)) ?? []
        }
    }

    func save(_ repairs: [CachedRepair]) {
        queue.sync {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let trimmed = Array(repairs.prefix(maxItems))
            if let data = try? encoder.encode(trimmed) {
                try? data.write(to: fileURL, options: [.atomic])
            }
        }
    }

    func upsert(_ repair: CachedRepair) {
        var current = load()
        current.removeAll { $0.id == repair.id }
        current.insert(repair, at: 0)
        save(current)
    }

    func remove(jobId: UUID) {
        var current = load()
        current.removeAll { $0.id == jobId }
        save(current)
    }

    func clear() {
        queue.sync {
            try? FileManager.default.removeItem(at: fileURL)
        }
    }
}
