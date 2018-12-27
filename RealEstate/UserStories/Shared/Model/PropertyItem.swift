//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import Foundation

struct PropertyItem: PropertyListItem {
    
    let id: PropertyID
    let isFavorite: Bool
    let title: String
    let address: String
    let price: String
    let image: URL?
    
}
