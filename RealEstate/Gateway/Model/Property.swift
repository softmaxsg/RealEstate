//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import Foundation

struct Property: Equatable, Decodable {
    
    let id: Int
    let title: String
    let price: Decimal
    let location: Location
    let images: [Image]
    
}
