//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import Foundation
@testable import RealEstate

final class FavoritesGatewayDelegateMock: FavoritesGatewayDelegate {

    typealias MethodImpl = (PropertyID) -> Void
    
    private let itemAddedImpl: MethodImpl
    private let itemRemovedImpl: MethodImpl
    
    init(itemAdded itemAddedImpl: @escaping MethodImpl,
         itemRemoved itemRemovedImpl: @escaping MethodImpl) {
        self.itemAddedImpl = itemAddedImpl
        self.itemRemovedImpl = itemRemovedImpl
    }

    func favoriteItemAdded(with id: PropertyID) {
        itemAddedImpl(id)
    }
    
    func favoriteItemRemoved(with id: PropertyID) {
        itemRemovedImpl(id)
    }
    
}
