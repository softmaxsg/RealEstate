//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import Foundation
@testable import RealEstate

final class FavoritesViewMock: FavoritesViewProtocol {
    
    typealias UpdateViewImpl = () -> Void
    
    private let updateViewImpl: UpdateViewImpl
    
    init(updateView: @escaping UpdateViewImpl) {
        self.updateViewImpl = updateView
    }
    
    func updateView() {
        updateViewImpl()
    }
        
}
