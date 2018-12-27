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
    
    // Basically this test just makes sure call does not crash
    // because all passed parameters can not be tested on presenter due to protection level
    func testItemPresenter() {
        let configurator = PropertiesListConfigurator()
        _ = configurator.presenter(for: Property.random(), in: PropertyItemViewMock.empty)
    }
    
    // Basically this test just makes sure call does not crash
    // because all passed parameters can not be tested on presenter due to protection level
    func testAdvertisementPresenter() {
        let configurator = PropertiesListConfigurator()
        _ = configurator.presenter(for: URL(string: UUID().uuidString)!, in: AdvertisementItemViewMock.empty)
    }

}
