//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import Foundation
@testable import RealEstate

extension PropertyItem {
    
    static func random() -> PropertyItem {
        return PropertyItem(
            id: PropertyID.random(in: 1...PropertyID.max),
            isFavorite: Bool.random(),
            title: UUID().uuidString,
            address: UUID().uuidString,
            price: UUID().uuidString,
            image: URL(string: UUID().uuidString)!
        )
    }
    
}

extension PropertyItem: Equatable {
    
    public static func == (lhs: PropertyItem, rhs: PropertyItem) -> Bool {
        return lhs.title == rhs.title &&
            lhs.address == rhs.address &&
            lhs.price == rhs.price &&
            lhs.image == rhs.image
    }
    
}
