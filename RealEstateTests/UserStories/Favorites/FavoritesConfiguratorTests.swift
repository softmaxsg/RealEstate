//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import XCTest
@testable import RealEstate

final class FavoritesConfiguratorTests: XCTestCase {
    
    func testViewControllerConfiguration() {
        let viewController = FavoritesCollectionViewController()
        viewController.configurator.configure(viewController: viewController)
        
        XCTAssertNotNil(viewController.presenter)
    }
    
}
