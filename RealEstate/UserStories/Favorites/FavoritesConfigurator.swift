//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import UIKit

protocol FavoritesConfiguratorProtocol {
    
    func configure(viewController: FavoritesCollectionViewController)
    func presenter(for property: Property, in itemView: PropertyItemViewProtocol) -> PropertyItemPresenterProtocol
    
}

final class FavoritesConfigurator: FavoritesConfiguratorProtocol {
    
    func configure(viewController: FavoritesCollectionViewController) {
        viewController.presenter = FavoritesPresenter(
            view: viewController,
            favoritesGateway: DependencyContainer.shared.favoritesGateway,
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

}
