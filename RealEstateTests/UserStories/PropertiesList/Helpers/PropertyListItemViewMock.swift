//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import Foundation
@testable import RealEstate

final class PropertyListItemViewMock<ItemType>: PropertyListItemViewProtocol where ItemType: PropertyListItem {

    typealias DisplayItemImpl = (ItemType) -> Void
    
    private let displayItemImpl: DisplayItemImpl
    
    init(displayItem: @escaping DisplayItemImpl) {
        self.displayItemImpl = displayItem
    }

    func display(item: ItemType) {
        displayItemImpl(item)
    }
    
}
