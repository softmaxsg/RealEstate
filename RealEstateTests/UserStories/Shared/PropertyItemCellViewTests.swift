//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import XCTest
@testable import RealEstate

class PropertyItemCellViewTests: XCTestCase {
    
    private let defaultSize = CGSize(width: 350, height: 250)
    
    private let expectedImageURL = URL(string: UUID().uuidString)!
    private let expectedImage = UIImage(named: "Test", in: Bundle(for: AdvertisementItemCellViewTests.self), compatibleWith: nil)!
    private lazy var imageLoaderMock = ImageLoaderMock { url, _, completion in
        completion(url, url == self.expectedImageURL ? self.expectedImage : nil)
        return EmptyTask()
    }
    
    private lazy var cell: PropertyItemCellView = {
        let cell: PropertyItemCellView = view(nibName: "PropertyItemView", size: defaultSize)
        cell.imageLoader = imageLoaderMock
        return cell
    }()
    
    func testLoadedImageAppearance() {
        let cell = self.cell
        cell.display(item: PropertyItem(
            id: 1,
            isFavorite: false,
            title: "Just an item",
            address: "Somewhere in the world",
            price: "€1,234",
            image: expectedImageURL
        ))
        
        snapshotVerifyView(cell)
    }
    
    func testLoadingImageFailedAppearance() {
        let cell = self.cell
        cell.display(item: PropertyItem(
            id: 1,
            isFavorite: false,
            title: "Another item",
            address: "Somewhere else in the world",
            price: "€9,876",
            image: nil
        ))
        
        snapshotVerifyView(cell)
    }
    
    func testLongLabelsAppearance() {
        let cell = self.cell
        cell.display(item: PropertyItem(
            id: 1,
            isFavorite: false,
            title: "An item with very long title to test how word wrapping works in the cell",
            address: "Somewhere else in the world where noone can find",
            price: "€9,876,543,210",
            image: nil
        ))
        
        snapshotVerifyView(cell)
    }
    
    func testFavoritePropertyAppearance() {
        let cell = self.cell
        cell.display(item: PropertyItem(
            id: 1,
            isFavorite: true,
            title: "Favorite item",
            address: "Somewhere in the world",
            price: "€1,234",
            image: expectedImageURL
        ))
        
        snapshotVerifyView(cell)
    }

}
