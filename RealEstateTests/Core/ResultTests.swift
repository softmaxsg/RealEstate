//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import XCTest
@testable import RealEstate

class ResultTests: XCTestCase {

    enum MockError: Error { case some }

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
        let result = Result<Void>(error: MockError.some)
        switch result {
        case .failure(let error as MockError):
            XCTAssertEqual(error, MockError.some)
        default:
            XCTFail()
        }
    }

    func testValueProperty() {
        let expectedValue = UUID()
        let result = Result.success(expectedValue)
        XCTAssertEqual(result.value, expectedValue)
    }
    
    func testErrorProperty() {
        let result = Result<Void>.failure(MockError.some)
        XCTAssertEqual(result.error as! MockError, MockError.some)
    }
    
}
