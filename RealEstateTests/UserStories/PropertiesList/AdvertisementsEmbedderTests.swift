//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import XCTest
@testable import RealEstate

final class AdvertisementsEmbedderTests: XCTestCase {

    private let properties = Array(1...Int.random(in: 3...10)).map { _ in PropertyItem.random() }
    private let advertisements = Array(1...Int.random(in: 1...10)).map { _ in AdvertisementItem.random() }

    func testCorrectAdvertisementsEmbedding() {
        let emberdder = AdvertisementsEmbedder()
        let result = emberdder.embed(advertisements, into: properties)

        var currentPropertyIndex = properties.startIndex
        var currentAdIndex = advertisements.startIndex
        for (index, item) in result.enumerated() {
            if (index + 1) % 3 == 0 {
                XCTAssertEqual(item.type, ItemType.advertisement, "Invalid item type at index \(index)")
                XCTAssertEqual(item.value as? AdvertisementItem, advertisements[currentAdIndex])
                
                advertisements.formIndex(after: &currentAdIndex)
                if currentAdIndex == advertisements.endIndex {
                    currentAdIndex = advertisements.startIndex
                }
            } else {
                XCTAssertEqual(item.type, ItemType.property, "Invalid item type at index \(index)")
                XCTAssertEqual(item.value as? PropertyItem, properties[currentPropertyIndex])
                
                properties.formIndex(after: &currentPropertyIndex)
            }
        }
    }
    
    func testEmbeddingWithoutAdvertisements() {
        let emberdder = AdvertisementsEmbedder()
        let result = emberdder.embed([], into: properties)
        let resultProperties = result.compactMap { $0.value as? PropertyItem }
        XCTAssertEqual(resultProperties, properties)
    }
    
    func testEmbeddingWithoutProperties() {
        let emberdder = AdvertisementsEmbedder()
        let result = emberdder.embed(advertisements, into: [])
        XCTAssertTrue(result.isEmpty)
    }

}
