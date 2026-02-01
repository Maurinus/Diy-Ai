import Foundation
import CoreLocation

struct CatalogItem: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let selectedVariant: String?
    let category: RepairCategory
    let hints: [String]

    init(id: UUID = UUID(), name: String, selectedVariant: String? = nil, category: RepairCategory, hints: [String] = []) {
        self.id = id
        self.name = name
        self.selectedVariant = selectedVariant
        self.category = category
        self.hints = hints
    }
}

enum SearchMode: Equatable {
    case geo(CLLocation)
    case postcode(String)
}

enum StockStatus: String, Codable {
    case inStock = "In stock"
    case lowStock = "Low stock"
    case outOfStock = "Out of stock"
    case unknown = "Unknown"
}

struct Coordinate: Codable, Equatable {
    let latitude: Double
    let longitude: Double

    var clLocationCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

struct LocalStoreOffer: Identifiable, Codable, Equatable {
    let id: UUID
    let storeName: String
    let address: String
    let distanceKm: Double?
    let price: Double
    let stockStatus: StockStatus
    let phone: String?
    let websiteURL: URL?
    let coordinate: Coordinate?
}

struct OnlineOffer: Identifiable, Codable, Equatable {
    let id: UUID
    let sellerName: String
    let price: Double
    let deliveryText: String
    let url: URL
}
