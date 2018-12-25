//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import UIKit

final class PropertiesListConfigurator {
    
    func configure(viewController: PropertiesListCollectionViewController) {
        let priceFormatter = NumberFormatter()
        priceFormatter.numberStyle = .currency
        priceFormatter.currencyCode = "EUR"
        priceFormatter.maximumFractionDigits = 0
        
        viewController.presenter = PropertiesListPresenter(
            view: viewController,
            propertiesGateway: PropertiesGateway(),
            favoritesGateway: FavoritesGateway(),
            advertisementsGateway: AdvertisementsGateway(),
            advertisementsEmbedder: AdvertisementsEmbedder(),
            priceFormatter: priceFormatter
        )

        viewController.imageLoader = ImageLoader()
    }
    
}
