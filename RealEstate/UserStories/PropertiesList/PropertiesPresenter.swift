//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import Foundation

protocol PropertiesPresenterProtocol {

    var propertiesCount: Int { get }
    
    func displayProperties()
    func configure(item: PropertyItemViewProtocol, at index: Int)

}

final class PropertiesPresenter: PropertiesPresenterProtocol {
    
    private weak var view: PropertiesViewProtocol?
    private let gateway: PropertiesGatewayProtocol
    private let priceFormatter: NumberFormatter

    private var properties: [Property] = []

    init(view: PropertiesViewProtocol, gateway: PropertiesGatewayProtocol, priceFormatter: NumberFormatter) {
        self.view = view
        self.gateway = gateway
        self.priceFormatter = priceFormatter
    }
    
    var propertiesCount: Int { return properties.count }
    
    func displayProperties() {
        gateway.loadAll { [weak self] result in
            switch result {
            case .success(let properties):
                self?.handleLoadedProperties(properties)
                
            case .failure(let error):
                self?.handleLoadingError(error)
            }
        }
    }
    
    func configure(item: PropertyItemViewProtocol, at index: Int) {
        guard properties.indices.contains(index) else { assertionFailure("Index \(index) is out of bounds"); return }
        let property = properties[index]
        item.display(item: PropertyItem(
            title: property.title,
            address: property.location.address,
            price: priceFormatter.string(from: NSDecimalNumber(decimal: property.price)) ?? "",
            image: property.images.first?.url
        ))
    }
    
}

extension PropertiesPresenter {
    
    private func handleLoadedProperties(_ properties: [Property]) {
        self.properties = properties
        view?.updateView()
    }
    
    private func handleLoadingError(_ error: Error) {
        view?.displayLoadingError(error.localizedDescription)
    }
    
}
