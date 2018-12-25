//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import XCTest
@testable import RealEstate

extension XCTest {
    
    func mockedDecoder(expectedData: Data, result: Result<[Property]>, expectation: XCTestExpectation, file: StaticString = #file, line: UInt = #line) -> JSONDecoderProtocol {
        return JSONDecoderMock<PropertiesResponse> { data in
            XCTAssertEqual(data, expectedData, file: file, line: line)
            expectation.fulfill()
            
            switch result {
            case .success(let items):
                return PropertiesResponse(items: items)
            case .failure(let error):
                throw error
            }
        }
    }
    
}
