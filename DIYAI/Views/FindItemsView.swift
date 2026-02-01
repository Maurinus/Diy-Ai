import SwiftUI
import CoreLocation

struct FindItemsView: View {
    @StateObject private var viewModel: FindItemsViewModel
    @EnvironmentObject private var locationService: LocationService
    @EnvironmentObject private var container: AppContainer
    @State private var modeChoice: ModeChoice = .location
    @FocusState private var postcodeFocused: Bool
    @State private var didTrackItemView = false

    private enum ModeChoice {
        case location
        case postcode
    }

    init(item: CatalogItem, service: StorePricingServiceProtocol) {
        _viewModel = StateObject(wrappedValue: FindItemsViewModel(item: item, service: service))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.l) {
                itemHeader
                modeSelection

                if viewModel.isLoading {
                    VStack(spacing: AppSpacing.s) {
                        SkeletonRow()
                        SkeletonRow()
                        SkeletonRow()
                    }
                }

                if let error = viewModel.errorMessage {
                    ErrorBanner(title: "We hit a snag", message: error, actionTitle: "Try again") {
                        viewModel.retry()
                    }
                }

                if let locationError = locationService.errorMessage {
                    ErrorBanner(title: "Location issue", message: locationError, actionTitle: "Try again") {
                        locationService.requestLocation()
                    }
                }

                if !viewModel.localOffers.isEmpty {
                    localResults
                }

                if !viewModel.onlineOffers.isEmpty {
                    onlineResults
                }
            }
            .padding(AppSpacing.l)
        }
        .background(AppColors.background)
        .navigationTitle("Find Items")
        .onChange(of: locationService.currentLocation) { _, location in
            guard modeChoice == .location, let location else { return }
            if case .geo = viewModel.mode { return }
            viewModel.search(mode: .geo(location))
        }
        .onChange(of: modeChoice) { _, newValue in
            if newValue == .postcode, viewModel.sortOption == .nearest {
                viewModel.sortOption = .bestValue
            }
        }
        .onChange(of: viewModel.localOffers) { _, _ in
            if availableSortOptions.contains(viewModel.sortOption) == false {
                viewModel.sortOption = .bestValue
            }
        }
        .onAppear {
            if !didTrackItemView {
                container.analytics.item_viewed(item: viewModel.item)
                didTrackItemView = true
            }
        }
    }

    private var itemHeader: some View {
        Card {
            HStack(spacing: AppSpacing.m) {
                ZStack {
                    Circle()
                        .fill(AppColors.accentSoft)
                        .frame(width: 56, height: 56)
                    Image(systemName: "cube.box.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(AppColors.accent)
                }
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("Selected item")
                        .font(.appCaption)
                        .foregroundColor(AppColors.textSecondary)
                    Text(viewModel.item.name)
                        .font(.appHeadline)
                    HStack(spacing: AppSpacing.xs) {
                        Pill(viewModel.item.category.displayName, color: AppColors.surfaceElevated)
                        if let variant = viewModel.item.selectedVariant {
                            Pill(variant, color: AppColors.surfaceElevated)
                        }
                    }
                    if !viewModel.item.hints.isEmpty {
                        Text(viewModel.item.hints.joined(separator: " • "))
                            .font(.appCaption)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                Spacer()
            }
        }
    }

    private var modeSelection: some View {
        Card {
            VStack(alignment: .leading, spacing: AppSpacing.m) {
                SectionHeader(title: "Find items", subtitle: "Choose how to search")

                HStack(spacing: AppSpacing.s) {
                    ModeSelectionButton(
                        title: "Use my location",
                        systemImage: "location.fill",
                        isSelected: modeChoice == .location
                    ) {
                        modeChoice = .location
                        locationService.requestLocation()
                        if let location = locationService.currentLocation {
                            viewModel.search(mode: .geo(location))
                        }
                    }
                    ModeSelectionButton(
                        title: "Enter postcode/suburb",
                        systemImage: "magnifyingglass",
                        isSelected: modeChoice == .postcode
                    ) {
                        modeChoice = .postcode
                        postcodeFocused = true
                    }
                }

                if modeChoice == .postcode {
                    HStack(spacing: AppSpacing.s) {
                        TextField("Postcode or suburb", text: $viewModel.postcode)
                            .textInputAutocapitalization(.never)
                            .focused($postcodeFocused)
                            .padding(AppSpacing.s)
                            .background(AppColors.surfaceElevated)
                            .cornerRadius(AppCornerRadius.s)
                        Button("Search") {
                            guard !viewModel.postcode.isEmpty else { return }
                            viewModel.search(mode: .postcode(viewModel.postcode))
                        }
                        .buttonStyle(SecondaryButtonStyle())
                        .frame(width: 110)
                    }
                }
            }
        }
    }

    private var localResults: some View {
        let cheapestId = viewModel.localOffers.min(by: { $0.price < $1.price })?.id
        let closestId = modeChoice == .location ? viewModel.localOffers.compactMap { offer -> (UUID, Double)? in
            guard let distance = offer.distanceKm else { return nil }
            return (offer.id, distance)
        }.min(by: { $0.1 < $1.1 })?.0
        : nil

        return VStack(alignment: .leading, spacing: AppSpacing.s) {
            SectionHeader(title: "Local stores", subtitle: "Showing \(viewModel.localOffers.count) stores")

            Picker("Sort", selection: $viewModel.sortOption) {
                ForEach(availableSortOptions) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .pickerStyle(.segmented)

            ForEach(Array(viewModel.sortedLocalOffers.prefix(10))) { offer in
                Card {
                    VStack(alignment: .leading, spacing: AppSpacing.s) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(offer.storeName)
                                    .font(.appHeadline)
                                Text(offer.address)
                                    .font(.appCaption)
                                    .foregroundColor(AppColors.textSecondary)
                                if let distance = offer.distanceKm {
                                    Text(String(format: "%.1f km away", distance))
                                        .font(.appCaption)
                                        .foregroundColor(AppColors.textSecondary)
                                } else if case let .postcode(code) = viewModel.mode {
                                    Text("Near \(code)")
                                        .font(.appCaption)
                                        .foregroundColor(AppColors.textSecondary)
                                }
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 4) {
                                Text(String(format: "$%.2f", offer.price))
                                    .font(.appTitle)
                                Pill(offer.stockStatus.rawValue, color: AppColors.surfaceElevated)
                                if offer.id == cheapestId {
                                    Pill("Best value", color: AppColors.accentSoft, textColor: AppColors.accent)
                                }
                                if offer.id == closestId {
                                    Pill("Closest", color: AppColors.accentSoft, textColor: AppColors.accent)
                                }
                            }
                        }
                        HStack(spacing: AppSpacing.s) {
                            if let coord = offer.coordinate {
                                let url = URL(string: "http://maps.apple.com/?daddr=\(coord.latitude),\(coord.longitude)")
                                if let url {
                                    LinkButton(title: "Directions", url: url, style: .secondary, onTap: {
                                        container.analytics.directions_clicked(item: viewModel.item, offer: offer)
                                    })
                                }
                            }
                            if let phone = offer.phone, let phoneURL = URL(string: "tel://\(phone)") {
                                LinkButton(title: "Call", url: phoneURL, style: .secondary)
                            }
                            if let website = offer.websiteURL {
                                LinkButton(title: "Website", url: website, style: .secondary, builder: container.affiliateLinkBuilder, onTap: {
                                    container.analytics.local_store_clicked(item: viewModel.item, offer: offer)
                                })
                            }
                        }
                    }
                }
            }
        }
    }

    private var onlineResults: some View {
        VStack(alignment: .leading, spacing: AppSpacing.s) {
            SectionHeader(title: "Order online", subtitle: "Delivered to your door")
            ForEach(viewModel.onlineOffers) { offer in
                Card {
                    VStack(alignment: .leading, spacing: AppSpacing.s) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(offer.sellerName)
                                    .font(.appHeadline)
                                Text(offer.deliveryText)
                                    .font(.appCaption)
                                    .foregroundColor(AppColors.textSecondary)
                            }
                            Spacer()
                            Text(String(format: "$%.2f", offer.price))
                                .font(.appHeadline)
                        }
                        LinkButton(title: "Order online", url: offer.url, style: .primary, builder: container.affiliateLinkBuilder, onTap: {
                            container.analytics.online_offer_clicked(item: viewModel.item, offer: offer)
                        })
                    }
                }
            }
        }
    }

    private var availableSortOptions: [FindItemsViewModel.SortOption] {
        if modeChoice == .location, viewModel.localOffers.contains(where: { $0.distanceKm != nil }) {
            return FindItemsViewModel.SortOption.allCases
        }
        return [.bestValue, .inStock]
    }
}

private struct ModeSelectionButton: View {
    let title: String
    let systemImage: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.xs) {
                Image(systemName: systemImage)
                Text(title)
                    .font(.appSubheadline)
            }
            .frame(maxWidth: .infinity, minHeight: 44)
            .foregroundColor(isSelected ? .white : AppColors.textPrimary)
            .background(isSelected ? AppColors.accent : AppColors.surfaceElevated)
            .overlay(
                RoundedRectangle(cornerRadius: AppCornerRadius.s)
                    .stroke(AppColors.border.opacity(isSelected ? 0 : 0.6), lineWidth: 1)
            )
            .cornerRadius(AppCornerRadius.s)
        }
    }
}
