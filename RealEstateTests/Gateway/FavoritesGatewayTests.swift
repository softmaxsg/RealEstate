//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import XCTest
@testable import RealEstate

final class FavoritesGatewayTests: XCTestCase {

    private let expectedProperty = Property.random()
    
    func testAddProperty() {
        let delegateExpectation = self.expectation(description: "FavoritesGatewayDelegate.favoriteItemAdded")
        let storageExpectation = self.expectation(description: "FavoritesDataStorage.saveAll")

        
        let delegateMock = FavoritesGatewayDelegateMock(
            itemAdded: { id in
                XCTAssertEqual(id, self.expectedProperty.id)
                delegateExpectation.fulfill()
            },
            itemRemoved: { _ in XCTFail("Should not be called") }
        )
        
        let gateway = FavoritesGateway(dataStorage: favoritesStorageMock(
            initial: [],
            expected: [expectedProperty],
            expectation: storageExpectation
        ))

        gateway.addDelegate(delegateMock)
        gateway.addProperty(expectedProperty)
        
        wait(for: [delegateExpectation, storageExpectation], timeout: 1)
        XCTAssertEqual(gateway.favorites, [expectedProperty])
    }
    
    func testRemoveProperty() {
        let delegateExpectation = self.expectation(description: "FavoritesGatewayDelegate.favoriteItemRemoved")
        let storageExpectation = self.expectation(description: "FavoritesDataStorage.saveAll")

        let delegateMock = FavoritesGatewayDelegateMock(
            itemAdded: { _ in XCTFail("Should not be called") },
            itemRemoved: { id in
                XCTAssertEqual(id, self.expectedProperty.id)
                delegateExpectation.fulfill()
            }
        )
        
        let gateway = FavoritesGateway(dataStorage: favoritesStorageMock(
            initial: [expectedProperty],
            expected: [],
            expectation: storageExpectation
        ))

        gateway.addDelegate(delegateMock)
        gateway.removeProperty(with: expectedProperty.id)
        
        wait(for: [delegateExpectation, storageExpectation], timeout: 1)
        XCTAssertTrue(gateway.favorites.isEmpty)
    }
    
    func testRemovedDelegate() {
        let delegateMock = FavoritesGatewayDelegateMock(
            itemAdded: { _ in XCTFail("Should not be called") },
            itemRemoved: { _ in XCTFail("Should not be called") }
        )

        let gateway = FavoritesGateway(dataStorage: favoritesStorageMock())
        gateway.addDelegate(delegateMock)
        gateway.removeDelegate(delegateMock)
        
        let expectedProperty = Property.random()
        gateway.addProperty(expectedProperty)
        gateway.removeProperty(with: expectedProperty.id)
    }
    
}
