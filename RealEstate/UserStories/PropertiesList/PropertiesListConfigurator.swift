//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import UIKit

protocol PropertiesListConfiguratorProtocol {
    
    func configure(viewController: PropertiesListCollectionViewController)
    
    func presenter(for property: Property, in itemView: PropertyItemViewProtocol) -> PropertyItemPresenterProtocol
    func presenter(for advertisementImageURL: URL, in itemView: AdvertisementItemViewProtocol) -> AdvertisementItemPresenterProtocol

}

final class PropertiesListConfigurator: PropertiesListConfiguratorProtocol {

    func configure(viewController: PropertiesListCollectionViewController) {
        viewController.presenter = PropertiesListPresenter(
            view: viewController,
            propertiesGateway: PropertiesGateway(),
            advertisementsGateway: AdvertisementsGateway(),
            advertisementsEmbedder: AdvertisementsEmbedder(),
            configurator: self
        )
    }

    func presenter(for property: Property, in itemView: PropertyItemViewProtocol) -> PropertyItemPresenterProtocol {
        return PropertyItemPresenter(
            view: itemView,
            property: property,
            favoritesGateway: DependencyContainer.shared.favoritesGateway,
            priceFormatter: DependencyContainer.shared.priceFormatter
        )
    }
    
    func presenter(for advertisementImageURL: URL, in itemView: AdvertisementItemViewProtocol) -> AdvertisementItemPresenterProtocol {
        return AdvertisementItemPresenter(
            view: itemView,
            advertisementImageURL: advertisementImageURL
        )
    }
    
}
