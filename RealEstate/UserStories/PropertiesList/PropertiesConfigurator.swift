//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import UIKit

final class PropertiesConfigurator {
    
    func configure(viewController: PropertiesCollectionViewController) {
        let priceFormatter = NumberFormatter()
        priceFormatter.numberStyle = .currency
        priceFormatter.currencyCode = "EUR"
        priceFormatter.maximumFractionDigits = 0
        
        viewController.presenter = PropertiesPresenter(
            view: viewController,
            gateway: PropertiesGateway(),
            priceFormatter: priceFormatter
        )
    }
    
}
