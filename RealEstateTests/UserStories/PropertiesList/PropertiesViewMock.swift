//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import Foundation
@testable import RealEstate

final class PropertiesViewMock: PropertiesViewProtocol {
    
    typealias UpdateViewImpl = () -> Void
    typealias DisplayLoadingErrorImpl = (String) -> Void

    private let updateViewImpl: UpdateViewImpl
    private let displayLoadingErrorImpl: DisplayLoadingErrorImpl
    
    init(updateView: @escaping UpdateViewImpl, displayLoadingError: @escaping DisplayLoadingErrorImpl) {
        self.updateViewImpl = updateView
        self.displayLoadingErrorImpl = displayLoadingError
    }

    func updateView() {
        updateViewImpl()
    }
    
    func displayLoadingError(_ message: String) {
        displayLoadingErrorImpl(message)
    }
    
}
