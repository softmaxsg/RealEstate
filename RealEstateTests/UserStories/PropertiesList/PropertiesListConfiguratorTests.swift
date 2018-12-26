//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import XCTest
@testable import RealEstate

final class PropertiesListConfiguratorTests: XCTestCase {

    func testViewControllerConfiguration() {
        let viewController = PropertiesListCollectionViewController()
        viewController.configurator.configure(viewController: viewController)
        
        XCTAssertNotNil(viewController.presenter)
    }

}
