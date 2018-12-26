//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import Foundation

extension PropertyItem {

    init(property: Property, favorite: Bool, priceFormatter: NumberFormatter) {
        id = property.id
        isFavorite = favorite
        title = property.title
        address = property.location.address
        price = priceFormatter.string(from: NSDecimalNumber(decimal: property.price)) ?? ""
        image = property.images.first?.url
    }
    
}
