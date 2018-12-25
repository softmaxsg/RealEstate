//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import XCTest
@testable import RealEstate

extension XCTest {
    
    func mockedSession(expectedURL: URL, resultStatusCode: Int, result: Result<Data>, expectation: XCTestExpectation, file: StaticString = #file, line: UInt = #line) -> URLSessionProtocol {
        return URLSessionMock { request, completion in
            XCTAssertEqual(request.url, expectedURL, file: file, line: line)
            return URLSessionDataTaskMock(
                resume: {
                    let urlResponse = HTTPURLResponse(
                        url: request.url!,
                        statusCode: resultStatusCode,
                        httpVersion: nil,
                        headerFields: nil
                    )
                    
                    OperationQueue.main.addOperation {
                        completion(result.value, urlResponse, result.error)
                        expectation.fulfill()
                    }
                },
                cancel: {
                    XCTFail("Should not be called in this test", file: file, line: line)
                }
            )
        }
    }

}
