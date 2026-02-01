import Foundation

protocol AnalyticsEvent {
    func item_viewed(item: CatalogItem)
    func local_store_clicked(item: CatalogItem, offer: LocalStoreOffer)
    func online_offer_clicked(item: CatalogItem, offer: OnlineOffer)
    func directions_clicked(item: CatalogItem, offer: LocalStoreOffer)
}

struct NoopAnalytics: AnalyticsEvent {
    func item_viewed(item: CatalogItem) {}
    func local_store_clicked(item: CatalogItem, offer: LocalStoreOffer) {}
    func online_offer_clicked(item: CatalogItem, offer: OnlineOffer) {}
    func directions_clicked(item: CatalogItem, offer: LocalStoreOffer) {}
}
