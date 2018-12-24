//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import XCTest
@testable import RealEstate

final class PropertiesListPresenterTests: XCTestCase {
    
    private let properties = Array(1...Int.random(in: 3...10)).map { _ in Property.random() }
    private let advertisements = Array(1...Int.random(in: 1...10)).map { _ in URL(string: UUID().uuidString)! }
    
    private lazy var priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "EUR"
        return formatter
    }()
    
    func testDispslayPropertiesSuccessful() {
        let presenter = presenterDisplayProperties(
            propertiesResult: .success(properties),
            advertisementsResult: .success(advertisements)
        )

        // Mocked AdvertisementsEmbedder just merges two arrays
        XCTAssertEqual(presenter.itemsCount, properties.count + advertisements.count)
        
        for (index, property) in properties.enumerated() {
            let item: PropertyItem = try! configureItem(presenter: presenter, at: index)
            compare(item: item, property: property)
        }
        
        for (index, url) in advertisements.enumerated() {
            let item: AdvertisementItem = try! configureItem(presenter: presenter, at: index + properties.count)
            compare(item: item, url: url)
        }
    }
    
    func testDispslayAdvertisementsFailed() {
        let presenter = presenterDisplayProperties(
            propertiesResult: .success(properties),
            advertisementsResult: .failure(MockError.some)
        )

        XCTAssertEqual(presenter.itemsCount, properties.count)
    }

    func testDispslayPropertiesFailed() {
        let presenter = presenterDisplayProperties(
            propertiesResult: .failure(MockError.some),
            advertisementsResult: .success(advertisements)
        )

        // Assert of the validity of the error message is tested in `presenterDisplayProperties`
        XCTAssertEqual(presenter.itemsCount, 0)
    }

    func testConfigurePropertyItem() {
        let presenter = presenterDisplayProperties(
            propertiesResult: .success(properties),
            advertisementsResult: .failure(MockError.some) // To simplify finding correct property in the list
        )
        
        let itemIndex = Int.random(in: 0..<properties.count)
        let item: PropertyItem = try! configureItem(presenter: presenter, at: itemIndex)
        let property = properties[itemIndex]

        compare(item: item, property: property)
    }

    func testConfigureAdvertisementItem() {
        let presenter = presenterDisplayProperties(
            propertiesResult: .success(properties),
            advertisementsResult: .success(advertisements)
        )

        let itemIndex = (0..<presenter.itemsCount).first(where: { try! presenter.itemType(at: $0) == .advertisement })!
        let item: AdvertisementItem = try! configureItem(presenter: presenter, at: itemIndex)
        
        compare(item: item, url: advertisements.first!)
    }

}

extension PropertiesListPresenterTests {
    
    private enum MockError: Error { case some }
    
    private func mockedViewSuccessState(expectation: XCTestExpectation, file: StaticString = #file, line: UInt = #line) -> PropertiesListViewProtocol {
        return PropertiesListViewMock(
            updateView: { expectation.fulfill() },
            displayLoadingError: { _ in XCTFail("Should not be called in this test", file: file, line: line) }
        )
    }
    
    private func presenterDisplayProperties(propertiesResult: Result<[Property]>, advertisementsResult: Result<[URL]>, file: StaticString = #file, line: UInt = #line) -> PropertiesListPresenterProtocol {
        let viewExpectation = self.expectation(description: "PropertiesView.updateView or displayLoadingError")
        let propertiesGatewayExpectation = self.expectation(description: "PropertiesGateway.loadAll")
        let advertisementsGatewayExpectation = self.expectation(description: "AdvertisementsGateway.loadAll")
        let advertisementsEmbedderExpectation = self.expectation(description: "AdvertisementsEmbedder.embed")

        let viewMock = PropertiesListViewMock(
            updateView: {
                switch propertiesResult {
                case .success:
                    viewExpectation.fulfill()
                case .failure:
                    XCTFail("Should not be called in this test", file: file, line: line)
                }
            },
            displayLoadingError: { errorMessage in
                switch propertiesResult {
                case .success:
                    XCTFail("Should not be called in this test", file: file, line: line)
                case .failure(let error):
                    XCTAssertEqual(errorMessage, error.localizedDescription, file: file, line: line)
                    viewExpectation.fulfill()
                }
            }
        )
        
        let propertiesGatewayMock = mockedPropertiesGateway(result: propertiesResult, expectation: propertiesGatewayExpectation)
        let advertisementsGatewayMock = mockedAdvertisementsGateway(result: advertisementsResult, expectation: advertisementsGatewayExpectation)
        
        let advertisementsEmbedderMock = AdvertisementsEmbedderMock { advertisements, properties in
            advertisementsEmbedderExpectation.fulfill()
            return properties.map { PropertyListItemInfo(type: .property, value: $0) } +
                advertisements.map { PropertyListItemInfo(type: .advertisement, value: $0) }
        }
        
        let presenter = PropertiesListPresenter(
            view: viewMock,
            propertiesGateway: propertiesGatewayMock,
            advertisementsGateway: advertisementsGatewayMock,
            advertisementsEmbedder: advertisementsEmbedderMock,
            priceFormatter: priceFormatter
        )
        
        presenter.displayProperties()
        
        if propertiesResult.value?.isEmpty ?? true {
            advertisementsEmbedderExpectation.fulfill()
        }

        wait(for: [viewExpectation, propertiesGatewayExpectation, advertisementsGatewayExpectation, advertisementsEmbedderExpectation], timeout: 1)
        return presenter
    }
    
    private func configureItem<ItemType>(presenter: PropertiesListPresenterProtocol, at index: Int) throws -> ItemType where ItemType: PropertyListItem {
        let expectation = self.expectation(description: "PropertyItemView.displayItem")
        var result: ItemType!
        
        try presenter.configure(item: PropertyListItemViewMock<ItemType> {
            result = $0
            expectation.fulfill()
        }, at: index)
        
        wait(for: [expectation], timeout: 1)
        return result
    }
    
    private func compare(item: PropertyItem, property: Property, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(item.title, property.title, file: file, line: line)
        XCTAssertEqual(item.address, property.location.address, file: file, line: line)
        XCTAssertEqual(item.price, priceFormatter.string(from: NSDecimalNumber(decimal: property.price)), file: file, line: line)
        XCTAssertEqual(item.image, property.images.first?.url, file: file, line: line)
    }
    
    private func compare(item: AdvertisementItem, url: URL, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(item.image, url, file: file, line: line)
    }

}
