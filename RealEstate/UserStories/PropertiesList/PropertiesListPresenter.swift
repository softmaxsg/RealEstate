//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import Foundation

enum PropertiesListPresenterError: Error {
    
    case indexOutOfBounds
    case invalidItemType
    
}

protocol PropertiesListPresenterProtocol {

    func displayProperties()
    
    var itemsCount: Int { get }
    func itemType(at index: Int) throws -> ItemType

    func configure<ViewType>(item: ViewType, at index: Int) throws where ViewType: PropertyListItemViewProtocol
    
    func toggleFavoriteState(at index: Int) throws

}

final class PropertiesListPresenter: PropertiesListPresenterProtocol {
    
    private weak var view: PropertiesListViewProtocol?
    private let propertiesGateway: PropertiesGatewayProtocol
    private let favoritesGateway: FavoritesGatewayProtocol
    private let advertisementsGateway: AdvertisementsGatewayProtocol
    private let advertisementsEmbedder: AdvertisementsEmbedderProtocol
    private let priceFormatter: NumberFormatter

    private var advertisements: [URL] = [] { didSet { embedAdvertisements() } }
    private var properties: [Property] = [] { didSet { embedAdvertisements() } }
    private var favorites = Set<Int>()
    private var items: [PropertyListItemInfo] = []

    init(view: PropertiesListViewProtocol,
         propertiesGateway: PropertiesGatewayProtocol,
         favoritesGateway: FavoritesGatewayProtocol,
         advertisementsGateway: AdvertisementsGatewayProtocol,
         advertisementsEmbedder: AdvertisementsEmbedderProtocol,
         priceFormatter: NumberFormatter) {
        self.view = view
        self.propertiesGateway = propertiesGateway
        self.favoritesGateway = favoritesGateway
        self.advertisementsGateway = advertisementsGateway
        self.advertisementsEmbedder = advertisementsEmbedder
        self.priceFormatter = priceFormatter
        
        self.favoritesGateway.addDelegate(self)
    }
    
    func displayProperties() {
        updateFavorites()
        loadAdvertisements()
        loadProperties()
    }
    
    var itemsCount: Int { return items.count }

    func itemType(at index: Int) throws -> ItemType {
        return try item(at: index).type
    }

    func configure<ViewType>(item itemView: ViewType, at index: Int) throws where ViewType: PropertyListItemViewProtocol {
        guard let item = try item(at: index).value as? ViewType.ItemType else { assertionFailure("Unexpected view type passed"); return }
        itemView.display(item: item)
    }

    func toggleFavoriteState(at index: Int) throws {
        let item = try self.item(at: index)
        guard item.type == .property else { throw PropertiesListPresenterError.invalidItemType }
        guard let propertyItem = item.value as? PropertyItem else { assertionFailure(); return }

        if propertyItem.isFavorite {
            favoritesGateway.removeProperty(with: propertyItem.id)
        } else {
            guard let property = properties.first(where: { $0.id == propertyItem.id }) else { assertionFailure(); return }
            favoritesGateway.addProperty(property)
        }
    }

}

extension PropertiesListPresenter {
    
    private func item(at index: Int) throws -> PropertyListItemInfo {
        guard items.indices.contains(index) else { throw PropertiesListPresenterError.indexOutOfBounds }
        return items[index]
    }
    
    private func itemIndex(with propertyID: Int) -> Int? {
        return items.firstIndex {
            return ($0.value as? PropertyItem)?.id == propertyID
        }
    }
    
    private func loadAdvertisements() {
        advertisementsGateway.loadAll { [weak self] result in
            OperationQueue.main.addOperation {
                switch result {
                case .success(let advertisements):
                    self?.advertisements = advertisements
                    
                case .failure:
                    // Errors on loading advertisements are not important for user
                    break
                }
            }
        }
    }
    
    private func loadProperties() {
        propertiesGateway.loadAll { [weak self] result in
            OperationQueue.main.addOperation {
                switch result {
                case .success(let properties):
                    self?.properties = properties
                    
                case .failure(let error):
                    self?.handleLoadingError(error)
                }
            }
        }
    }
    
    private func updateFavorites() {
        favorites = Set(favoritesGateway.favorites.map { $0.id })
    }

    private func makePropertyItem(with property: Property) -> PropertyItem {
        return PropertyItem(
            id: property.id,
            isFavorite: favorites.contains(property.id),
            title: property.title,
            address: property.location.address,
            price: priceFormatter.string(from: NSDecimalNumber(decimal: property.price)) ?? "",
            image: property.images.first?.url
        )
    }
    
    private func embedAdvertisements() {
        guard !(self.properties.isEmpty && self.items.isEmpty) else { return }
        
        let advertisements = self.advertisements.map(AdvertisementItem.init)
        let properties = self.properties.map { makePropertyItem(with: $0) }
        
        items = advertisementsEmbedder.embed(advertisements, into: properties)
        view?.updateView()
    }
    
    private func handleLoadingError(_ error: Error) {
        view?.displayLoadingError(error.localizedDescription)
    }
    
}

extension PropertiesListPresenter: FavoritesGatewayDelegate {
    
    func favoriteItemAdded(with id: Int) {
        favoriteStateDidUpdate(with: id)
    }
    
    func favoriteItemRemoved(with id: Int) {
        favoriteStateDidUpdate(with: id)
    }
    
    private func favoriteStateDidUpdate(with id: Int) {
        updateFavorites()
        
        guard let itemIndex = itemIndex(with: id) else { return }
        guard let property = properties.first(where: { $0.id == id }) else { assertionFailure(); return }
        
        items[itemIndex] = PropertyListItemInfo(type: .property, value: makePropertyItem(with: property))
        view?.updateItem(at: itemIndex)
    }
    
}
