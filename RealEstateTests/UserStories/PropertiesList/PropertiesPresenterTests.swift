//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import XCTest
@testable import RealEstate

final class PropertiesPresenterTests: XCTestCase {
    
    private let properties = Array(repeating: 0, count: Int.random(in: 1...10)).map { _ in Property.random() }
    private lazy var priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "EUR"
        return formatter
    }()
    
    func testDispslayPropertiesSuccessful() {
        let presenter = presenterLoadProperties(result: .success(properties))
        XCTAssertEqual(presenter.propertiesCount, properties.count)
    }
    
    func testDispslayPropertiesFailed() {
        _ = presenterLoadProperties(result: .failure(MockError.some))
        // Assert is not needed since validity of the error message is tested in `presenterLoadProperties`
    }
    
    func testConfigureItem() {
        let presenter = presenterLoadProperties(result: .success(properties))
        
        let itemIndex = Int.random(in: 0..<properties.count)
        let item = configureItem(presenter: presenter, at: itemIndex)
        let property = properties[itemIndex]

        XCTAssertEqual(item.title, property.title)
        XCTAssertEqual(item.address, property.location.address)
        XCTAssertEqual(item.price, priceFormatter.string(from: NSDecimalNumber(decimal: property.price)))
        XCTAssertEqual(item.image, property.images.first?.url)
    }

}

extension PropertiesPresenterTests {
    
    private enum MockError: Error { case some }
    
    private func mockedGateway(result: Result<[Property]>, expectation: XCTestExpectation) -> PropertiesGatewayProtocol {
        return PropertiesGatewayMock { handler in
            OperationQueue.main.addOperation {
                handler(result)
                expectation.fulfill()
            }
            
            return EmptyTask()
        }
    }
    
    private func mockedViewSuccessState(expectation: XCTestExpectation, file: StaticString = #file, line: UInt = #line) -> PropertiesViewProtocol {
        return PropertiesViewMock(
            updateView: { expectation.fulfill() },
            displayLoadingError: { _ in XCTFail("Should not be called in this test", file: file, line: line) }
        )
    }
    
    private func presenterLoadProperties(result: Result<[Property]>, file: StaticString = #file, line: UInt = #line) -> PropertiesPresenterProtocol {
        let viewExpectation = self.expectation(description: "PropertiesView.updateView or displayLoadingError")
        let gatewayExpectation = self.expectation(description: "PropertiesGateway.loadAll")
        
        let viewMock = PropertiesViewMock(
            updateView: {
                switch result {
                case .success:
                    viewExpectation.fulfill()
                case .failure:
                    XCTFail("Should not be called in this test", file: file, line: line)
                }
            },
            displayLoadingError: { errorMessage in
                switch result {
                case .success:
                    XCTFail("Should not be called in this test", file: file, line: line)
                case .failure(let error):
                    XCTAssertEqual(errorMessage, error.localizedDescription, file: file, line: line)
                    viewExpectation.fulfill()
                }
            }
        )
        
        let gatewayMock = mockedGateway(result: result, expectation: gatewayExpectation)
        
        let presenter = PropertiesPresenter(
            view: viewMock,
            gateway: gatewayMock,
            priceFormatter: priceFormatter
        )
        
        presenter.displayProperties()
        wait(for: [viewExpectation, gatewayExpectation], timeout: 1)
        
        return presenter
    }
    
    private func configureItem(presenter: PropertiesPresenterProtocol, at index: Int) -> PropertyItem {
        let expectation = self.expectation(description: "PropertyItemView.displayItem")
        var result: PropertyItem!
        
        presenter.configure(item: PropertyItemViewMock {
            result = $0
            expectation.fulfill()
        }, at: index)
        
        wait(for: [expectation], timeout: 1)
        return result
    }

}
