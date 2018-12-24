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

    private struct Item {
        let type: ItemType
        let value: PropertyListItem
        
    }
    
    private weak var view: PropertiesListViewProtocol?
    private let propertiesGateway: PropertiesGatewayProtocol
    private let advertisementsGateway: AdvertisementsGatewayProtocol
    private let priceFormatter: NumberFormatter

    private var advertisements: [URL] = [] { didSet { embedAdvertisements() } }
    private var properties: [Property] = [] { didSet { embedAdvertisements() } }
    private var items: [Item] = []

    init(view: PropertiesListViewProtocol,
         propertiesGateway: PropertiesGatewayProtocol,
         advertisementsGateway: AdvertisementsGatewayProtocol,
         priceFormatter: NumberFormatter) {
        self.view = view
        self.propertiesGateway = propertiesGateway
        self.advertisementsGateway = advertisementsGateway
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
    
    private func item(at index: Int) throws -> Item {
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
        guard !properties.isEmpty else { return }
        var items: [Item] = []
        
        var currentAdIndex = advertisements.startIndex
        for (index, property) in properties.enumerated() {
            if index > 0 && index % 2 == 0 {
                if currentAdIndex < advertisements.endIndex {
                    items.append(Item(
                        type: .advertisement,
                        value: AdvertisementItem(image: advertisements[currentAdIndex])
                    ))
                    
                    advertisements.formIndex(after: &currentAdIndex)
                    if currentAdIndex == advertisements.endIndex {
                        currentAdIndex = advertisements.startIndex
                    }
                }
            }
            
            items.append(Item(
                type: .property,
                value: PropertyItem(
                    title: property.title,
                    address: property.location.address,
                    price: priceFormatter.string(from: NSDecimalNumber(decimal: property.price)) ?? "",
                    image: property.images.first?.url
                )
            ))
        }
        
        self.items = items
        view?.updateView()
    }
    
    private func handleLoadingError(_ error: Error) {
        view?.displayLoadingError(error.localizedDescription)
    }
    
}
