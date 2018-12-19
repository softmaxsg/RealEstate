//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import XCTest
@testable import RealEstate

class ResultTests: XCTestCase {

    func testInitializationWithSuccessValue() {
        let expectedValue = UUID()
        let result = Result(value: expectedValue)
        switch result {
        case .success(let value):
            XCTAssertEqual(value, expectedValue)
        default:
            XCTFail()
        }
    }
    
    func testInitializationWithFailureValue() {
        enum MockError: Error { case some }
        let result = Result<Void>(error: MockError.some)
        switch result {
        case .failure(let error as MockError):
            XCTAssertEqual(error, MockError.some)
        default:
            XCTFail()
        }
    }

}
