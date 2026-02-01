import Foundation
import CoreLocation

@MainActor
final class FindItemsViewModel: ObservableObject {
    enum SortOption: String, CaseIterable, Identifiable {
        case bestValue = "Cheapest"
        case nearest = "Nearest"
        case inStock = "In stock"

        var id: String { rawValue }
    }

    let item: CatalogItem
    private let service: StorePricingServiceProtocol

    @Published var mode: SearchMode?
    @Published var postcode: String = ""
    @Published var isLoading: Bool = false
    @Published var localOffers: [LocalStoreOffer] = []
    @Published var onlineOffers: [OnlineOffer] = []
    @Published var sortOption: SortOption = .bestValue
    @Published var errorMessage: String?
    private var lastMode: SearchMode?

    init(item: CatalogItem, service: StorePricingServiceProtocol) {
        self.item = item
        self.service = service
    }

    func search(mode: SearchMode) {
        self.mode = mode
        self.lastMode = mode
        errorMessage = nil
        isLoading = true

        Task {
            let localOffers = service.searchLocal(item: item, mode: mode)
            let onlineOffers = service.searchOnline(item: item)
            await MainActor.run {
                self.localOffers = localOffers
                self.onlineOffers = onlineOffers
                self.isLoading = false
            }
        }
    }

    func retry() {
        guard let lastMode else { return }
        search(mode: lastMode)
    }

    var sortedLocalOffers: [LocalStoreOffer] {
        switch sortOption {
        case .bestValue:
            return localOffers.sorted { $0.price < $1.price }
        case .nearest:
            return localOffers.sorted { ($0.distanceKm ?? 9999) < ($1.distanceKm ?? 9999) }
        case .inStock:
            return localOffers.sorted { stockRank($0.stockStatus) < stockRank($1.stockStatus) }
        }
    }

    private func stockRank(_ status: StockStatus) -> Int {
        switch status {
        case .inStock: return 0
        case .lowStock: return 1
        case .unknown: return 2
        case .outOfStock: return 3
        }
    }
}
