//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import XCTest
@testable import RealEstate

final class LocationDecodingTests: XCTestCase, DecodingTester {

    typealias Object = Location
    
    let expectedObject = Location.random()
    let requiredFields = ["address", "latitude", "longitude"]
    
    func testFullDecoding() {
        performFullDecodingTest()
    }
    
    func testRequiredFields() {
        performRequiredFieldsTest()
    }

}
