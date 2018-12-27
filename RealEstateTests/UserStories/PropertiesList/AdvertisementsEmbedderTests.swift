//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import XCTest
@testable import RealEstate

final class AdvertisementsEmbedderTests: XCTestCase {

    private let properties = Array(1...Int.random(in: 3...10)).map { _ in Property.random() }
    private let advertisements = Array(1...Int.random(in: 1...10)).map { _ in URL(string: UUID().uuidString)! }

    func testCorrectAdvertisementsEmbedding() {
        let emberdder = AdvertisementsEmbedder()
        let result = emberdder.embed(advertisements, into: properties)

        var currentPropertyIndex = properties.startIndex
        var currentAdIndex = advertisements.startIndex
        for (index, item) in result.enumerated() {
            let isAdvertisementIndex = (index + 1) % 3 == 0
            switch item {
            case .advertisement(let imageUrl):
                XCTAssertTrue(isAdvertisementIndex, "Invalid item type at index \(index)")
                XCTAssertEqual(imageUrl, advertisements[currentAdIndex])
                
                advertisements.formIndex(after: &currentAdIndex)
                if currentAdIndex == advertisements.endIndex {
                    currentAdIndex = advertisements.startIndex
                }

            case .property(let property):
                XCTAssertFalse(isAdvertisementIndex, "Invalid item type at index \(index)")
                XCTAssertEqual(property, properties[currentPropertyIndex])
                
                properties.formIndex(after: &currentPropertyIndex)
            }
        }
    }
    
    func testEmbeddingWithoutAdvertisements() {
        let emberdder = AdvertisementsEmbedder()
        let result = emberdder.embed([], into: properties)
        let resultProperties: [Property] = result.compactMap {
            switch $0 {
            case .property(let property): return property
            case .advertisement: return nil
            }
        }
        XCTAssertEqual(resultProperties, properties)
    }
    
    func testEmbeddingWithoutProperties() {
        let emberdder = AdvertisementsEmbedder()
        let result = emberdder.embed(advertisements, into: [])
        XCTAssertTrue(result.isEmpty)
    }

}
