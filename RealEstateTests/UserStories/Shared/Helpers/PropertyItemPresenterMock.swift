//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import Foundation
@testable import RealEstate

final class PropertItemPresenterMock: PropertyItemPresenterProtocol {
    
    typealias MethodImpl = () -> Void
    
    private let updateViewImpl: MethodImpl
    private let toggleFavoriteStateImpl: MethodImpl
    
    init(updateView updateViewImpl: @escaping MethodImpl,
         toggleFavoriteState toggleFavoriteStateImpl: @escaping MethodImpl) {
        self.updateViewImpl = updateViewImpl
        self.toggleFavoriteStateImpl = toggleFavoriteStateImpl
    }
    
    func updateView() {
        updateViewImpl()
    }
    
    func toggleFavoriteState() {
        toggleFavoriteStateImpl()
    }

}

extension PropertItemPresenterMock {
    
    static var empty: PropertyItemPresenterProtocol {
        return PropertItemPresenterMock(
            updateView: { },
            toggleFavoriteState: { }
        )
    }
    
}
