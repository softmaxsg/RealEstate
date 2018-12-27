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
    
    // Basically this test just makes sure call does not crash
    // because all passed parameters can not be tested on presenter due to protection level
    func testItemPresenter() {
        let configurator = FavoritesConfigurator()
        _ = configurator.presenter(for: Property.random(), in: PropertyItemViewMock.empty)
    }
    
}
