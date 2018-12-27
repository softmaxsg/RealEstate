//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import Foundation
@testable import RealEstate

final class PropertyItemViewMock: PropertyItemViewProtocol {

    typealias DisplayItemImpl = (PropertyItem) -> Void
    
    private let displayItemImpl: DisplayItemImpl
    
    init(displayItem: @escaping DisplayItemImpl) {
        self.displayItemImpl = displayItem
    }

    func display(item: PropertyItem) {
        displayItemImpl(item)
    }
    
}

extension PropertyItemViewMock {
    
    static var empty: PropertyItemViewProtocol {
        return PropertyItemViewMock(displayItem: { _ in })
    }
    
}
