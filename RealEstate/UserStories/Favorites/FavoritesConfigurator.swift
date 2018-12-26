//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import UIKit

final class FavoritesConfigurator {
    
    func configure(viewController: FavoritesCollectionViewController) {
        viewController.presenter = FavoritesPresenter(
            view: viewController,
            favoritesGateway: DependencyContainer.shared.favoritesGateway,
            priceFormatter: DependencyContainer.shared.priceFormatter
        )
    }
    
}
