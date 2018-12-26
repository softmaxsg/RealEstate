//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import UIKit

final class PropertiesListConfigurator {
    
    func configure(viewController: PropertiesListCollectionViewController) {
        viewController.presenter = PropertiesListPresenter(
            view: viewController,
            propertiesGateway: PropertiesGateway(),
            favoritesGateway: DependencyContainer.shared.favoritesGateway,
            advertisementsGateway: AdvertisementsGateway(),
            advertisementsEmbedder: AdvertisementsEmbedder(),
            priceFormatter: DependencyContainer.shared.priceFormatter
        )
    }
    
}
