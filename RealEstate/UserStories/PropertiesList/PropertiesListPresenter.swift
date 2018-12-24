//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import Foundation

enum PropertiesListPresenterError: Error {
    
    case indexOutOfBounds
    
}

protocol PropertiesListPresenterProtocol {

    func displayProperties()
    
    var itemsCount: Int { get }
    func itemType(at index: Int) throws -> ItemType

    func configure<ViewType>(item: ViewType, at index: Int) throws where ViewType: PropertyListItemViewProtocol

}

final class PropertiesListPresenter: PropertiesListPresenterProtocol {
    
    private weak var view: PropertiesListViewProtocol?
    private let propertiesGateway: PropertiesGatewayProtocol
    private let advertisementsGateway: AdvertisementsGatewayProtocol
    private let advertisementsEmbedder: AdvertisementsEmbedderProtocol
    private let priceFormatter: NumberFormatter

    private var advertisements: [URL] = [] { didSet { embedAdvertisements() } }
    private var properties: [Property] = [] { didSet { embedAdvertisements() } }
    private var items: [PropertyListItemInfo] = []

    init(view: PropertiesListViewProtocol,
         propertiesGateway: PropertiesGatewayProtocol,
         advertisementsGateway: AdvertisementsGatewayProtocol,
         advertisementsEmbedder: AdvertisementsEmbedderProtocol,
         priceFormatter: NumberFormatter) {
        self.view = view
        self.propertiesGateway = propertiesGateway
        self.advertisementsGateway = advertisementsGateway
        self.advertisementsEmbedder = advertisementsEmbedder
        self.priceFormatter = priceFormatter
    }
    
    func displayProperties() {
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

}

extension PropertiesListPresenter {
    
    private func item(at index: Int) throws -> PropertyListItemInfo {
        guard items.indices.contains(index) else { throw PropertiesListPresenterError.indexOutOfBounds }
        return items[index]
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
    
    private func embedAdvertisements() {
        guard !(self.properties.isEmpty && self.items.isEmpty) else { return }
        
        let advertisements = self.advertisements.map(AdvertisementItem.init)
        let properties = self.properties.map { property in
            PropertyItem(
                title: property.title,
                address: property.location.address,
                price: priceFormatter.string(from: NSDecimalNumber(decimal: property.price)) ?? "",
                image: property.images.first?.url
            )
        }
        
        items = advertisementsEmbedder.embed(advertisements, into: properties)
        view?.updateView()
    }
    
    private func handleLoadingError(_ error: Error) {
        view?.displayLoadingError(error.localizedDescription)
    }
    
}
