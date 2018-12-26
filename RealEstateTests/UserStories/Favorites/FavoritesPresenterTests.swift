//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import XCTest
@testable import RealEstate

final class FavoritesPresenterTests: XCTestCase {

    private let favorites = Array(1...Int.random(in: 1...10)).map { _ in Property.random() }

    private lazy var priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "EUR"
        return formatter
    }()
    
    func testDispslayFavoritesSuccessful() {
        let presenter = presenterDisplayFavorites(initial: favorites)
        XCTAssertEqual(presenter.itemsCount, favorites.count)
        
        for (index, property) in favorites.enumerated() {
            let item = try! configureItem(presenter: presenter, at: index)
            compare(item: item, property: property)
        }
    }

    func testDispslayFavoritesEmpty() {
        let presenter = presenterDisplayFavorites(initial: [])
        XCTAssertEqual(presenter.itemsCount, 0)
    }

    func testInvalidIndex() {
        let presenter = presenterDisplayFavorites(initial: favorites)
        XCTAssertThrowsError(try configureItem(presenter: presenter, at: presenter.itemsCount), "Has to throw an error") { error in
            XCTAssertEqual(error as? RandomAccessCollectionError, RandomAccessCollectionError.indexOutOfBounds)
        }
    }

    func testConfigurePropertyItem() {
        let presenter = presenterDisplayFavorites(initial: favorites)
        
        let itemIndex = Int.random(in: 0..<favorites.count)
        let item = try! configureItem(presenter: presenter, at: itemIndex)
        let property = favorites[itemIndex]
        
        compare(item: item, property: property)
    }
    
}

extension FavoritesPresenterTests {
    
    private enum MockError: Error { case some }
    
    private func presenterDisplayFavorites(initial favorites: [Property], file: StaticString = #file, line: UInt = #line) -> FavoritesPresenterProtocol {
        let viewExpectation = self.expectation(description: "FavoritesView.updateView")
        
        let viewMock = FavoritesViewMock { viewExpectation.fulfill() }
        
        let presenter = FavoritesPresenter(
            view: viewMock,
            favoritesGateway: FavoritesGateway(dataStorage: favoritesStorageMock(initial: favorites)),
            priceFormatter: priceFormatter
        )
        
        presenter.displayFavorites()
        
        wait(for: [viewExpectation], timeout: 1)
        return presenter
    }

    private func configureItem(presenter: FavoritesPresenterProtocol, at index: Int) throws -> PropertyItem {
        let expectation = self.expectation(description: "PropertyItemView.displayItem")
        var result: Result<PropertyItem>!
        
        do {
            try presenter.configure(item: PropertyItemViewMock {
                result = .success($0)
                expectation.fulfill()
            }, at: index)
        } catch (let error) {
            result = .failure(error)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
        
        switch result! {
        case .success(let value): return value
        case .failure(let error): throw error
        }
    }

    private func compare(item: PropertyItem, property: Property, file: StaticString = #file, line: UInt = #line) {
        XCTAssertTrue(item.isFavorite)
        XCTAssertEqual(item.id, property.id, file: file, line: line)
        XCTAssertEqual(item.title, property.title, file: file, line: line)
        XCTAssertEqual(item.address, property.location.address, file: file, line: line)
        XCTAssertEqual(item.price, priceFormatter.string(from: NSDecimalNumber(decimal: property.price)), file: file, line: line)
        XCTAssertEqual(item.image, property.images.first?.url, file: file, line: line)
    }

}