//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import XCTest
@testable import RealEstate

final class PropertiesConfiguratorTests: XCTestCase {

    func testViewControllerConfiguration() {
        let viewController = PropertiesCollectionViewController()
        viewController.configurator.configure(viewController: viewController)
        
        XCTAssertNotNil(viewController.presenter)
        XCTAssertNotNil(viewController.imageLoader)
    }

}
