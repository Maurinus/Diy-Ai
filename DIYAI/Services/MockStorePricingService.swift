import Foundation

final class MockStorePricingService: StorePricingServiceProtocol {
    private let fixture: StoreOffersFixture
    private let affiliateLinkBuilder: AffiliateLinkBuilder

    init(affiliateLinkBuilder: AffiliateLinkBuilder) {
        self.affiliateLinkBuilder = affiliateLinkBuilder
        if let url = Bundle.main.url(forResource: "store_offers", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let fixture = try? JSONDecoder().decode(StoreOffersFixture.self, from: data) {
            self.fixture = fixture
        } else {
            self.fixture = StoreOffersFixture(localOffers: [], onlineOffers: [])
        }
    }

    func searchLocal(item: CatalogItem, mode: SearchMode) -> [LocalStoreOffer] {
        var offers = fixture.localOffers
        switch mode {
        case .geo:
            break
        case .postcode:
            offers = offers.map { offer in
                LocalStoreOffer(
                    id: offer.id,
                    storeName: offer.storeName,
                    address: offer.address,
                    distanceKm: nil,
                    price: offer.price,
                    stockStatus: offer.stockStatus,
                    phone: offer.phone,
                    websiteURL: offer.websiteURL,
                    coordinate: offer.coordinate
                )
            }
        }
        return offers
    }

    func searchOnline(item: CatalogItem) -> [OnlineOffer] {
        fixture.onlineOffers.map { offer in
            OnlineOffer(
                id: offer.id,
                sellerName: offer.sellerName,
                price: offer.price,
                deliveryText: offer.deliveryText,
                url: affiliateLinkBuilder.build(offer.url)
            )
        }
    }
}

struct StoreOffersFixture: Codable {
    let localOffers: [LocalStoreOffer]
    let onlineOffers: [OnlineOffer]
}
