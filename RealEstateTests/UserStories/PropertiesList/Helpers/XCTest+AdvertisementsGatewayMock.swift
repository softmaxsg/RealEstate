//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import XCTest
@testable import RealEstate

extension XCTest {
    
    func mockedAdvertisementsGateway(result: Result<[URL]>, expectation: XCTestExpectation) -> AdvertisementsGatewayProtocol {
        return AdvertisementsGatewayMock { handler in
            OperationQueue.main.addOperation {
                handler(result)
                expectation.fulfill()
            }
            
            return EmptyTask()
        }
    }
    
}
