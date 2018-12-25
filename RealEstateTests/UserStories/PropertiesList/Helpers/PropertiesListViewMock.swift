//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import Foundation
@testable import RealEstate

final class PropertiesListViewMock: PropertiesListViewProtocol {
    
    typealias UpdateViewImpl = () -> Void
    typealias UpdateItemImpl = (Int) -> Void
    typealias DisplayLoadingErrorImpl = (String) -> Void

    private let updateViewImpl: UpdateViewImpl
    private let updateItemImpl: UpdateItemImpl
    private let displayLoadingErrorImpl: DisplayLoadingErrorImpl
    
    init(updateView: @escaping UpdateViewImpl,
         updateItem updateItemImpl: @escaping UpdateItemImpl,
         displayLoadingError: @escaping DisplayLoadingErrorImpl) {
        self.updateViewImpl = updateView
        self.updateItemImpl = updateItemImpl
        self.displayLoadingErrorImpl = displayLoadingError
    }

    func updateView() {
        updateViewImpl()
    }
    
    func updateItem(at index: Int) {
        updateItemImpl(index)
    }
    
    func displayLoadingError(_ message: String) {
        displayLoadingErrorImpl(message)
    }
    
}
