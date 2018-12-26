//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import Foundation

// Simple light version dependency container for shared dependencies
final class DependencyContainer {
    
    static let shared = DependencyContainer()

    var priceFormatter: NumberFormatter {
        let priceFormatter = NumberFormatter()
        priceFormatter.numberStyle = .currency
        priceFormatter.currencyCode = "EUR"
        priceFormatter.maximumFractionDigits = 0
        return priceFormatter
    }
    
    let imageLoader = ImageLoader()
    let favoritesGateway = FavoritesGateway(dataStorage: FavoritesDataStorage())
    
}
