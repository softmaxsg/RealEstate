//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import XCTest
@testable import RealEstate

final class PropertiesGatewayTests: XCTestCase {

    private let expectedURL = URL(string: "https://private-91146-mobiletask.apiary-mock.com/realestates")!
    private let expectedData = Data()
    private let expectedProperties: [Property] = [.random()]

    func testLoadAllSuccessful() {
        let sessionExpectation = self.expectation(description: "URLSession.dataTask")
        let decoderExpectation = self.expectation(description: "JSONDecoder.decode")

        let gateway = PropertiesGateway(
            urlSession: mockedSession(expectedURL: expectedURL, resultStatusCode: 200, result: expectedData, expectation: sessionExpectation),
            jsonDecoder: mockedDecoder(expectedData: expectedData, result: expectedProperties, expectation: decoderExpectation)
        )
        
        let result = loadAllProperties(gateway: gateway)
        XCTAssertEqual(result.value, expectedProperties)
        
        // Make sure all expectations were fulfilled
        wait(for: [sessionExpectation, decoderExpectation], timeout: 1)
    }
    
    func testLoadAllLoadingFailed() {
        let sessionExpectation = self.expectation(description: "URLSession.dataTask")
        
        let gateway = PropertiesGateway(
            urlSession: mockedSession(expectedURL: expectedURL, resultStatusCode: 500, result: nil, expectation: sessionExpectation),
            jsonDecoder: JSONDecoderMock<[Property]> { _ in
                XCTFail("Should not be called in this test")
                fatalError()
            }
        )
        
        let result = loadAllProperties(gateway: gateway)
        XCTAssertEqual(result.error as? MockError, MockError.urlSession)
        
        // Make sure all expectations were fulfilled
        wait(for: [sessionExpectation], timeout: 1)
    }
    
    func testLoadAllDecodingFailed() {
        let sessionExpectation = self.expectation(description: "URLSession.dataTask")
        let decoderExpectation = self.expectation(description: "JSONDecoder.decode")

        let gateway = PropertiesGateway(
            urlSession: mockedSession(expectedURL: expectedURL, resultStatusCode: 200, result: expectedData, expectation: sessionExpectation),
            jsonDecoder: mockedDecoder(expectedData: expectedData, result: nil, expectation: decoderExpectation)
        )

        let result = loadAllProperties(gateway: gateway)
        XCTAssertEqual(result.error as? MockError, MockError.jsonDecoder)

        // Make sure all expectations were fulfilled
        wait(for: [sessionExpectation, decoderExpectation], timeout: 1)
    }

}

extension PropertiesGatewayTests {

    enum MockError: Error {
        case urlSession
        case jsonDecoder
    }
    
    private func mockedSession(expectedURL: URL, resultStatusCode: Int, result: Data?, expectation: XCTestExpectation, file: StaticString = #file, line: UInt = #line) -> URLSessionProtocol {
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
                        let error = result == nil ? MockError.urlSession : nil
                        completion(result, urlResponse, error)
                        expectation.fulfill()
                    }
                },
                cancel: {
                    XCTFail("Should not be called in this test", file: file, line: line)
                }
            )
        }
    }
    
    private func mockedDecoder(expectedData: Data, result: [Property]?, expectation: XCTestExpectation, file: StaticString = #file, line: UInt = #line) -> JSONDecoderProtocol {
        return JSONDecoderMock<PropertiesResponse> { data in
            XCTAssertEqual(data, expectedData, file: file, line: line)
            expectation.fulfill()

            guard let result = result else { throw MockError.jsonDecoder }
            return PropertiesResponse(items: result)
        }
    }
    
    private func loadAllProperties(gateway: PropertiesGateway) -> Result<[Property]> {
        let expectation = self.expectation(description: "PropertiesGateway.loadAll")
        var result: Result<[Property]>!
        
        gateway.loadAll {
            result = $0
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
        return result
    }

}
