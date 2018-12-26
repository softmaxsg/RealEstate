//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import Foundation
@testable import RealEstate

final class FavoritesViewMock: FavoritesViewProtocol {
    
    typealias UpdateViewImpl = () -> Void
    typealias UpdateItemImpl = (Int) -> Void

    private let updateViewImpl: UpdateViewImpl
    private let insertItemImpl: UpdateItemImpl
    private let removeItemImpl: UpdateItemImpl

    
    init(updateView updateViewImpl: @escaping UpdateViewImpl,
         insertItem insertItemImpl: @escaping UpdateItemImpl,
         removeItem removeItemImpl: @escaping UpdateItemImpl) {
        self.updateViewImpl = updateViewImpl
        self.insertItemImpl = insertItemImpl
        self.removeItemImpl = removeItemImpl
    }
    
    func updateView() {
        updateViewImpl()
    }

    func insertItem(at index: Int) {
        insertItemImpl(index)
    }
    
    func removeItem(at index: Int) {
        removeItemImpl(index)
    }

}
