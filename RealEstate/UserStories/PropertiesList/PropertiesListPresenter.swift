//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import Foundation

enum PropertiesListPresenterError: Error {

    case invalidViewType

}

protocol PropertiesListPresenterProtocol {

    func displayProperties()
    
    var itemsCount: Int { get }
    
    func itemType(at index: Int) throws -> ItemType
    func itemPresenter(for itemView: PropertyListItemViewProtocol, at index: Int) throws -> PropertyListItemPresenterProtocol

}

final class PropertiesListPresenter: PropertiesListPresenterProtocol {
    
    private weak var view: PropertiesListViewProtocol?
    private let propertiesGateway: PropertiesGatewayProtocol
    private let advertisementsGateway: AdvertisementsGatewayProtocol
    private let advertisementsEmbedder: AdvertisementsEmbedderProtocol
    private let configurator: PropertiesListConfiguratorProtocol

    private var advertisements: [URL] = [] { didSet { embedAdvertisements() } }
    private var properties: [Property] = [] { didSet { embedAdvertisements() } }
    private var items: [PropertyListItemInfo] = []

    init(view: PropertiesListViewProtocol,
         propertiesGateway: PropertiesGatewayProtocol,
         advertisementsGateway: AdvertisementsGatewayProtocol,
         advertisementsEmbedder: AdvertisementsEmbedderProtocol,
         configurator: PropertiesListConfiguratorProtocol) {
        self.view = view
        self.propertiesGateway = propertiesGateway
        self.advertisementsGateway = advertisementsGateway
        self.advertisementsEmbedder = advertisementsEmbedder
        self.configurator = configurator
    }
    
    func displayProperties() {
        loadAdvertisements()
        loadProperties()
    }
    
    var itemsCount: Int { return items.count }

    func itemType(at index: Int) throws -> ItemType {
        let item = try items.item(at: index)
        switch item {
        case .property: return .property
        case .advertisement: return .advertisement
        }
    }

    func itemPresenter(for itemView: PropertyListItemViewProtocol, at index: Int) throws -> PropertyListItemPresenterProtocol {
        let item = try items.item(at: index)
        switch item {
        case .property(let property):
            guard let propertyItemView = itemView as? PropertyItemViewProtocol else { throw PropertiesListPresenterError.invalidViewType }
            return configurator.presenter(for: property, in: propertyItemView)
        case .advertisement(let imageURL):
            guard let advertisementItemView = itemView as? AdvertisementItemViewProtocol else { throw PropertiesListPresenterError.invalidViewType }
            return configurator.presenter(for: imageURL, in: advertisementItemView)
        }
    }

}

extension PropertiesListPresenter {
    
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
        items = advertisementsEmbedder.embed(advertisements, into: properties)
        view?.updateView()
    }
    
    private func handleLoadingError(_ error: Error) {
        view?.displayLoadingError(error.localizedDescription)
    }
    
}
