//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import Foundation
@testable import RealEstate

final class AdvertisementItemViewMock: AdvertisementItemViewProtocol {
    
    typealias DisplayItemImpl = (AdvertisementItem) -> Void
    
    private let displayItemImpl: DisplayItemImpl
    
    init(displayItem: @escaping DisplayItemImpl) {
        self.displayItemImpl = displayItem
    }
    
    func display(item: AdvertisementItem) {
        displayItemImpl(item)
    }
    
}

extension AdvertisementItemViewMock {
    
    static var empty: AdvertisementItemViewProtocol {
        return AdvertisementItemViewMock { _ in }
    }
    
}
