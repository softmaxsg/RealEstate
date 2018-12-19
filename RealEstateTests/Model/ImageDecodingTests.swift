//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import XCTest
@testable import RealEstate

class ImageDecodingTests: XCTestCase, DecodingTester {

    typealias Object = Image
    
    let expectedObject = Image.random()
    let requiredFields = ["id", "url"]
    
    func testFullDecoding() {
        performFullDecodingTest()
    }
    
    func testRequiredFields() {
        performRequiredFieldsTest()
    }

}
