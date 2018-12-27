//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import Foundation
@testable import RealEstate

final class AdvertisementItemPresenterMock: AdvertisementItemPresenterProtocol {
    
    typealias MethodImpl = () -> Void
    
    private let updateViewImpl: MethodImpl
    
    init(updateView updateViewImpl: @escaping MethodImpl) {
        self.updateViewImpl = updateViewImpl
    }
    
    func updateView() {
        updateViewImpl()
    }
    
}

extension AdvertisementItemPresenterMock {
    
    static var empty: AdvertisementItemPresenterProtocol {
        return AdvertisementItemPresenterMock { }
    }
    
}
