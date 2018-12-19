//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import XCTest
@testable import RealEstate

class PropertyDecodingTests: XCTestCase, DecodingTester {
    
    typealias Object = Property

    let expectedObject = Property.random()
    let requiredFields = ["id", "title", "price", "location"]
    
    func testFullDecoding() {
        performFullDecodingTest()
    }

    func testRequiredFields() {
        performRequiredFieldsTest()
    }

    func testOptionalFields() {
        let json = fullJSON.removingValue(forKey: "images")
        let decodedObject = try? JSONDecoder().decode(Property.self, from: json)
        XCTAssertNotNil(decodedObject, "Field `images` is optional")
        XCTAssertEqual(decodedObject!.images, [], "Missed field `images` has to be mapped to an empty array")
    }

}
