import Foundation

protocol StorePricingServiceProtocol {
    func searchLocal(item: CatalogItem, mode: SearchMode) -> [LocalStoreOffer]
    func searchOnline(item: CatalogItem) -> [OnlineOffer]
}
