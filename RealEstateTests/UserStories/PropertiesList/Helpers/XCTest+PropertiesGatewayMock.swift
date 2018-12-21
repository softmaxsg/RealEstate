//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import XCTest
@testable import RealEstate

extension XCTest {
    
    func mockedGateway(result: Result<[Property]>, expectation: XCTestExpectation) -> PropertiesGatewayProtocol {
        return PropertiesGatewayMock { handler in
            OperationQueue.main.addOperation {
                handler(result)
                expectation.fulfill()
            }
            
            return EmptyTask()
        }
    }
    
}
