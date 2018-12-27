//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import XCTest
@testable import RealEstate

class AdvertisementItemPresenterTests: XCTestCase {
    
    func testUpdateView() {
        let viewExpectation = self.expectation(description: "AdvertisementItemCellView.display")
        
        let advertisementImageURL = URL(string: UUID().uuidString)!
        
        let viewMock = AdvertisementItemViewMock { item in
            XCTAssertEqual(item.image, advertisementImageURL)
            viewExpectation.fulfill()
        }
        
        let presenter = AdvertisementItemPresenter(
            view: viewMock,
            advertisementImageURL: advertisementImageURL
        )
        
        presenter.updateView()
        wait(for: [viewExpectation], timeout: 1)
    }
    
}
