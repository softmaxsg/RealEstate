//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import XCTest
@testable import RealEstate

extension XCTestCase {

    func favoritesStorageMock(initial initialFavorites: [Property]? = nil,
                              expected expectedFavorites: [Property]? = nil,
                              expectation: XCTestExpectation? = nil,
                              file: StaticString = #file,
                              line: UInt = #line) -> FavoritesDataStorageProtocol {
        return FavoritesDataStorageMock(
            loadAll: { return initialFavorites ?? [] },
            saveAll: { favorites in
                if let expectedFavorites = expectedFavorites {
                    XCTAssertEqual(favorites, expectedFavorites, file: file, line: line)
                }
                
                expectation?.fulfill()
            }
        )
    }

}
