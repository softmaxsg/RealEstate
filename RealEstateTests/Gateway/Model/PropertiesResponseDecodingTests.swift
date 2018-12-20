//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import XCTest
@testable import RealEstate

final class PropertiesResponseDecodingTests: XCTestCase, DecodingTester {
    
    typealias Object = PropertiesResponse
    
    let expectedObject = PropertiesResponse.random()
    let requiredFields = ["items"]
    
    func testFullDecoding() {
        performFullDecodingTest()
    }
    
    func testRequiredFields() {
        performRequiredFieldsTest()
    }
    
}
