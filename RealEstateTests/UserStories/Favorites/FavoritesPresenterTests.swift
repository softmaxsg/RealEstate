//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import XCTest
@testable import RealEstate

final class FavoritesPresenterTests: XCTestCase {

    private let favorites = Array(1...Int.random(in: 1...10)).map { _ in Property.random() }

    func testDispslayFavoritesSuccessful() {
        var expectedProperty: Property!
        var expectedItemPresenter: PropertyItemPresenterProtocol!
        
        let itemViewMock = PropertyItemViewMock.empty
        let presenter = presenterDisplayFavorites(initial: favorites, itemPresenter: { property, itemView in
            XCTAssertTrue(itemView === itemViewMock)
            XCTAssertEqual(property, expectedProperty)
            expectedItemPresenter = PropertItemPresenterMock.empty
            return expectedItemPresenter
        })

        XCTAssertEqual(presenter.itemsCount, favorites.count)

        for (index, property) in favorites.enumerated() {
            expectedProperty = property
            
            let itemPresenter = try! presenter.itemPresenter(for: itemViewMock, at: index)
            XCTAssertTrue(itemPresenter === expectedItemPresenter)
        }
    }

    func testDispslayFavoritesEmpty() {
        let presenter = presenterDisplayFavorites(initial: [])
        XCTAssertEqual(presenter.itemsCount, 0)
    }

    func testInvalidIndex() {
        let presenter = presenterDisplayFavorites(initial: favorites, itemPresenter: { property, itemView in
            XCTFail("Should not be called")
            fatalError()
        })

        XCTAssertThrowsError(try presenter.itemPresenter(for: PropertyItemViewMock.empty, at: presenter.itemsCount), "Has to throw an error") { error in
            XCTAssertEqual(error as? RandomAccessCollectionError, RandomAccessCollectionError.indexOutOfBounds)
        }
    }
    
    func testFavoritesGatewayDelegate() {
        let itemIndex = Int.random(in: 0..<favorites.count)
        let expectedProperty = favorites[itemIndex]
        
        var configured = false
        let viewMock = FavoritesViewMock(
            updateView: { XCTAssertFalse(configured, "Should not be called after initial configuration") },
            insertItem: { index in XCTAssertEqual(index, itemIndex) },
            removeItem: { index in XCTAssertEqual(index, itemIndex) }
        )
        
        let presenter = presenterDisplayFavorites(initial: favorites, view: viewMock) as! FavoritesGatewayDelegate
        configured = true
        
        presenter.favoriteItemAdded(with: expectedProperty.id)
        presenter.favoriteItemRemoved(with: expectedProperty.id)
    }

}

extension FavoritesPresenterTests {
    
    private func presenterDisplayFavorites(initial initialFavorites: [Property],
                                           view: FavoritesViewProtocol? = nil,
                                           itemPresenter: FavoritesConfiguratorMock.PresenterForPropertyImpl? = nil,
                                           file: StaticString = #file,
                                           line: UInt = #line) -> FavoritesPresenterProtocol {
        let viewExpectation = self.expectation(description: "FavoritesView.updateView")
        
        let viewMock = view ?? FavoritesViewMock(
            updateView: { viewExpectation.fulfill() },
            insertItem: { _ in XCTFail("Should not be called", file: file, line: line) },
            removeItem: { _ in XCTFail("Should not be called", file: file, line: line) }
        )
        
        let favoritesStorageMock = self.favoritesStorageMock(initial: initialFavorites)
        
        let configuratorMock = FavoritesConfiguratorMock(
            configure: { _ in },
            presenter: itemPresenter ?? { _, _ in PropertItemPresenterMock.empty }
        )
        
        let presenter = FavoritesPresenter(
            view: viewMock,
            favoritesGateway: FavoritesGateway(dataStorage: favoritesStorageMock),
            configurator: configuratorMock
        )
        
        presenter.displayFavorites()
        if view != nil { viewExpectation.fulfill() }
        
        wait(for: [viewExpectation], timeout: 1)
        return presenter
    }

}
