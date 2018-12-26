//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import XCTest
@testable import RealEstate

final class PropertiesListPresenterTests: XCTestCase {
    
    private let properties = Array(1...Int.random(in: 3...10)).map { _ in Property.random() }
    private let advertisements = Array(1...Int.random(in: 1...10)).map { _ in URL(string: UUID().uuidString)! }
    private lazy var favorites: [Property] = {
        return properties.compactMap { Bool.random() ? $0 : nil }
    }()
    
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
    
    func testInvalidIndex() {
        let presenter = presenterDisplayProperties(
            propertiesResult: .success(properties),
            advertisementsResult: .success(advertisements)
        )
        
        XCTAssertThrowsError(try presenter.itemType(at: presenter.itemsCount), "Has to throw an error") { error in
            XCTAssertEqual(error as? PropertiesListPresenterError, PropertiesListPresenterError.indexOutOfBounds)
        }
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
    
    func testTogglePropertyFavoriteState() {
        let updateItemExpectation = self.expectation(description: "PropertiesView.updateItem")
        let favoritesGatewayExpectation = self.expectation(description: "FavoritesGateway.addProperty or removeProperty")

        var item: PropertyItem!
        var favoriteState: Bool!
        let itemIndex = Int.random(in: 0..<self.properties.count)

        let defaultFavoritesGateway = FavoritesGateway(dataStorage: favoritesStorageMock(initial: favorites))
        let favoritesGatewayMock = FavoritesGatewayMock(
            getFavorites: { defaultFavoritesGateway.favorites },
            addProperty: { property in
                guard !item.isFavorite else { XCTFail("Should not be called"); fatalError() }
                defaultFavoritesGateway.addProperty(property)
                favoriteState = true
                favoritesGatewayExpectation.fulfill()
            },
            removeProperty: { id in
                guard item.isFavorite else { XCTFail("Should not be called"); fatalError() }
                defaultFavoritesGateway.removeProperty(with: id)
                favoriteState = false
                favoritesGatewayExpectation.fulfill()
            },
            addDelegate: { defaultFavoritesGateway.addDelegate($0) },
            removeDelegate: { defaultFavoritesGateway.removeDelegate($0) }
        )
        
        let presenter = presenterDisplayProperties(
            propertiesResult: .success(properties),
            advertisementsResult: .failure(MockError.some), // To simplify finding correct property in the list
            updateItemImpl: { index in
                XCTAssertEqual(index, itemIndex)
                updateItemExpectation.fulfill()
            },
            favoritesGateway: favoritesGatewayMock,
            additionalActions: { presenter in
                // Has to be done within the scope of `presenterDisplayProperties` in order to keep view mock alive during this call
                item = try! self.configureItem(presenter: presenter, at: itemIndex)
                try! presenter.toggleFavoriteState(at: itemIndex)
            }
        )
        
        wait(for: [updateItemExpectation, favoritesGatewayExpectation], timeout: 1)
        
        let updatedItem: PropertyItem = try! configureItem(presenter: presenter, at: itemIndex)
        XCTAssertEqual(updatedItem.isFavorite, favoriteState)
        XCTAssertNotEqual(updatedItem.isFavorite, item.isFavorite)
    }

    func testToggleAdvertisementFavoriteState() {
        let presenter = presenterDisplayProperties(
            propertiesResult: .success(properties),
            advertisementsResult: .success(advertisements)
        )
        
        let itemIndex = (0..<presenter.itemsCount).first(where: { try! presenter.itemType(at: $0) == .advertisement })!
        XCTAssertThrowsError(try presenter.toggleFavoriteState(at: itemIndex), "Has to throw an error") { error in
            XCTAssertEqual(error as? PropertiesListPresenterError, PropertiesListPresenterError.invalidItemType)
        }
    }

}

extension PropertiesListPresenterTests {
    
    private enum MockError: Error { case some }
    
    private func presenterDisplayProperties(propertiesResult: Result<[Property]>,
                                            advertisementsResult: Result<[URL]>,
                                            updateItemImpl: PropertiesListViewMock.UpdateItemImpl? = nil,
                                            favoritesGateway: FavoritesGatewayProtocol? = nil,
                                            additionalActions: ((PropertiesListPresenterProtocol) -> Void)? = nil,
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
            updateItem: updateItemImpl ?? { _ in XCTFail("Should not be called in this test", file: file, line: line) },
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
            favoritesGateway: favoritesGateway ?? FavoritesGateway(dataStorage: favoritesStorageMock(initial: favorites)),
            advertisementsGateway: advertisementsGatewayMock,
            advertisementsEmbedder: advertisementsEmbedderMock,
            priceFormatter: priceFormatter
        )
        
        presenter.displayProperties()
        
        if propertiesResult.value?.isEmpty ?? true {
            advertisementsEmbedderExpectation.fulfill()
        }

        wait(for: [viewExpectation, propertiesGatewayExpectation, advertisementsGatewayExpectation, advertisementsEmbedderExpectation], timeout: 1)
        additionalActions?(presenter)
        
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
        XCTAssertEqual(item.id, property.id, file: file, line: line)
        XCTAssertEqual(item.isFavorite, favorites.contains(property), file: file, line: line)
        XCTAssertEqual(item.title, property.title, file: file, line: line)
        XCTAssertEqual(item.address, property.location.address, file: file, line: line)
        XCTAssertEqual(item.price, priceFormatter.string(from: NSDecimalNumber(decimal: property.price)), file: file, line: line)
        XCTAssertEqual(item.image, property.images.first?.url, file: file, line: line)
    }
    
    private func compare(item: AdvertisementItem, url: URL, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(item.image, url, file: file, line: line)
    }

}
