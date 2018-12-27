//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import XCTest
@testable import RealEstate

final class PropertiesListPresenterTests: XCTestCase {
    
    private let properties = Array(1...Int.random(in: 3...10)).map { _ in Property.random() }
    private let advertisements = Array(1...Int.random(in: 1...10)).map { _ in URL(string: UUID().uuidString)! }
    
    func testDispslayPropertiesSuccessful() {
        var expectedProperty: Property!
        var expectedAdvertisement: URL!
        var expectedItemPresenter: PropertyListItemPresenterProtocol!
        
        let propertyItemViewMock = PropertyItemViewMock.empty
        let advertisementItemViewMock = AdvertisementItemViewMock.empty

        let presenter = presenterDisplayProperties(
            propertiesResult: .success(properties),
            advertisementsResult: .success(advertisements),
            propertyItemPresenter: { property, itemView in
                XCTAssertTrue(itemView === propertyItemViewMock)
                XCTAssertEqual(property, expectedProperty)
                expectedItemPresenter = PropertItemPresenterMock.empty
                return expectedItemPresenter as! PropertyItemPresenterProtocol
            },
            advertisementItemPresenter: { advertisement, itemView in
                XCTAssertTrue(itemView === advertisementItemViewMock)
                XCTAssertEqual(advertisement, expectedAdvertisement)
                expectedItemPresenter = AdvertisementItemPresenterMock.empty
                return expectedItemPresenter as! AdvertisementItemPresenterProtocol
            }
        )

        // Mocked AdvertisementsEmbedder just merges two arrays
        XCTAssertEqual(presenter.itemsCount, properties.count + advertisements.count)

        expectedAdvertisement = nil
        for (index, property) in properties.enumerated() {
            expectedProperty = property
            
            let itemType = try! presenter.itemType(at: index)
            XCTAssertEqual(itemType, .property)
            
            let itemPresenter = try! presenter.itemPresenter(for: propertyItemViewMock, at: index)
            XCTAssertTrue(itemPresenter === expectedItemPresenter)
        }
        
        expectedProperty = nil
        for (index, advertisement) in advertisements.enumerated() {
            expectedAdvertisement = advertisement
            
            let itemType = try! presenter.itemType(at: properties.count + index)
            XCTAssertEqual(itemType, .advertisement)
            
            let itemPresenter = try! presenter.itemPresenter(for: advertisementItemViewMock, at: properties.count + index)
            XCTAssertTrue(itemPresenter === expectedItemPresenter)
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
    
    func testInvalidIndex() {
        let presenter = presenterDisplayProperties(
            propertiesResult: .success(properties),
            advertisementsResult: .success(advertisements)
        )
        
        XCTAssertThrowsError(try presenter.itemType(at: presenter.itemsCount), "Has to throw an error") { error in
            XCTAssertEqual(error as? RandomAccessCollectionError, RandomAccessCollectionError.indexOutOfBounds)
        }
    }

}

extension PropertiesListPresenterTests {
    
    private enum MockError: Error { case some }
    
    private func presenterDisplayProperties(propertiesResult: Result<[Property]>,
                                            advertisementsResult: Result<[URL]>,
                                            propertyItemPresenter: PropertiesListConfiguratorMock.PresenterForPropertyImpl? = nil,
                                            advertisementItemPresenter: PropertiesListConfiguratorMock.PresenterForAdvertisementImpl? = nil,
                                            file: StaticString = #file,
                                            line: UInt = #line) -> PropertiesListPresenterProtocol {
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
            return properties.map { .property($0) } + advertisements.map { .advertisement($0) }
        }
        
        let configurationMock = PropertiesListConfiguratorMock(
            configure: { _ in },
            propertyPresenter: propertyItemPresenter ?? { _, _ in PropertItemPresenterMock.empty },
            advertisementPresenter: advertisementItemPresenter ?? { _, _ in AdvertisementItemPresenterMock.empty }
        )
        
        let presenter = PropertiesListPresenter(
            view: viewMock,
            propertiesGateway: propertiesGatewayMock,
            advertisementsGateway: advertisementsGatewayMock,
            advertisementsEmbedder: advertisementsEmbedderMock,
            configurator: configurationMock
        )
        
        presenter.displayProperties()
        
        if propertiesResult.value?.isEmpty ?? true {
            advertisementsEmbedderExpectation.fulfill()
        }

        wait(for: [viewExpectation, propertiesGatewayExpectation, advertisementsGatewayExpectation, advertisementsEmbedderExpectation], timeout: 1)
        
        return presenter
    }

}
