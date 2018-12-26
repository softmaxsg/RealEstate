//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import XCTest
@testable import RealEstate

final class FavoritesDataStorageTests: XCTestCase {

    private let expectedProperties = Array(1...Int.random(in: 1...10)).map { _ in Property.random() }

    private let storageUrl = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)

    override func tearDown() {
        try? FileManager.default.removeItem(at: storageUrl)
    }
    
    // No separate tests for loading and saving because it's not easy to mock dependencies for FavoritesDataStorage
    func testSaveAndLoad() {
        let savingStorage = FavoritesDataStorage(url: storageUrl)
        savingStorage.saveAll(expectedProperties)

        let readingStorage = FavoritesDataStorage(url: storageUrl)
        let properties = readingStorage.loadAll()
        
        XCTAssertEqual(properties, expectedProperties)
    }
    
    func testLoadFailed() {
        let storage = FavoritesDataStorage(url: URL(fileURLWithPath: UUID().uuidString))
        let properties = storage.loadAll()
        XCTAssertTrue(properties.isEmpty)
    }

}
