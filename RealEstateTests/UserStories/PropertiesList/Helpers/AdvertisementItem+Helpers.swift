//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import Foundation
@testable import RealEstate

extension AdvertisementItem {
    
    static func random() -> AdvertisementItem {
        return AdvertisementItem(
            image: URL(string: UUID().uuidString)!
        )
    }
    
}

extension AdvertisementItem: Equatable {
    
    public static func == (lhs: AdvertisementItem, rhs: AdvertisementItem) -> Bool {
        return lhs.image == rhs.image
    }
    
}
