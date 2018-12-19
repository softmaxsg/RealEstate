//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import XCTest

protocol DecodingTester {
    
    associatedtype Object: Decodable, Equatable
    
    var expectedObject: Object { get }
    var fullJSON: [String: Any] { get }
    var requiredFields: [String] { get }
}

extension DecodingTester where Object: JSONPresentable {
    
    var fullJSON: [String: Any] {
        return expectedObject.JSON()
    }
    
}

extension DecodingTester {
    
    func performFullDecodingTest(file: StaticString = #file, line: UInt = #line) {
        let decodedObject = try? JSONDecoder().decode(Object.self, from: fullJSON)
        XCTAssertNotNil(decodedObject, file: file, line: line)
        XCTAssertEqual(decodedObject!, expectedObject, file: file, line: line)
        
    }
    
    func performRequiredFieldsTest(file: StaticString = #file, line: UInt = #line) {
        requiredFields.forEach { field in
            let currentJSON = fullJSON.removingValue(forKey: field)
            let decodedObject = try? JSONDecoder().decode(Object.self, from: currentJSON)
            XCTAssertNil(decodedObject, "Field `\(field)` has to be required", file: file, line: line)
        }
        
    }
    
}
