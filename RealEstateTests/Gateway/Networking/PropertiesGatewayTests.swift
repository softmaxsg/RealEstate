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
            urlSession: mockedSession(expectedURL: expectedURL, resultStatusCode: 200, result: .success(expectedData), expectation: sessionExpectation),
            jsonDecoder: mockedDecoder(expectedData: expectedData, result: .success(expectedProperties), expectation: decoderExpectation)
        )
        
        let result = loadAllProperties(gateway: gateway)
        XCTAssertEqual(result.value, expectedProperties)
        
        // Make sure all expectations were fulfilled
        wait(for: [sessionExpectation, decoderExpectation], timeout: 1)
    }
    
    func testLoadAllLoadingFailed() {
        let sessionExpectation = self.expectation(description: "URLSession.dataTask")
        
        let gateway = PropertiesGateway(
            urlSession: mockedSession(expectedURL: expectedURL, resultStatusCode: 500, result: .failure(MockError.urlSession), expectation: sessionExpectation),
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
            urlSession: mockedSession(expectedURL: expectedURL, resultStatusCode: 200, result: .success(expectedData), expectation: sessionExpectation),
            jsonDecoder: mockedDecoder(expectedData: expectedData, result: .failure(MockError.jsonDecoder), expectation: decoderExpectation)
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
