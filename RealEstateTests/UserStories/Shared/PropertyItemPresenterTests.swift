//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import XCTest
@testable import RealEstate

class PropertyItemPresenterTests: XCTestCase {

    private lazy var priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "EUR"
        return formatter
    }()

    func testUpdateView() {
        perform(
            action: { $0.updateView() },
            validation: { item, property, isFavorite in
                self.compare(item: item, property: property, isFavorite: isFavorite)
            }
        )
    }

    func testToggleFavoriteState() {
        perform(
            action: { $0.toggleFavoriteState() },
            validation: { item, property, isFavorite in
                self.compare(item: item, property: property, isFavorite: !isFavorite)
            }
        )
    }

}

extension PropertyItemPresenterTests {
    
    private func perform(action: (PropertyItemPresenter) -> Void, validation: @escaping (PropertyItem, Property, Bool) -> Void, file: StaticString = #file, line: UInt = #line) {
        let viewExpectation = self.expectation(description: "PropertyItemCellView.display")
        
        let property = Property.random()
        let isFavorite = Bool.random()
        
        let viewMock = PropertyItemViewMock { item in
            validation(item, property, isFavorite)
            viewExpectation.fulfill()
        }
        
        let favoritesStorageMock = self.favoritesStorageMock(
            initial: isFavorite ? [property] : [],
            expected: isFavorite ? [] : [property]
        )
        
        let presenter = PropertyItemPresenter(
            view: viewMock,
            property: property,
            favoritesGateway: FavoritesGateway(dataStorage: favoritesStorageMock),
            priceFormatter: priceFormatter
        )
        
        action(presenter)
        wait(for: [viewExpectation], timeout: 1)
    }
    
    private func compare(item: PropertyItem, property: Property, isFavorite: Bool, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(item.id, property.id, file: file, line: line)
        XCTAssertEqual(item.isFavorite, isFavorite, file: file, line: line)
        XCTAssertEqual(item.title, property.title, file: file, line: line)
        XCTAssertEqual(item.address, property.location.address, file: file, line: line)
        XCTAssertEqual(item.price, priceFormatter.string(from: NSDecimalNumber(decimal: property.price)), file: file, line: line)
        XCTAssertEqual(item.image, property.images.first?.url, file: file, line: line)
    }

}
