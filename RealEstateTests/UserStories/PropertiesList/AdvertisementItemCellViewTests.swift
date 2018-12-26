//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import XCTest
@testable import RealEstate

class AdvertisementItemCellViewTests: XCTestCase {

    private let defaultSize = CGSize(width: 350, height: 250)
    
    private let expectedImageURL = URL(string: UUID().uuidString)!
    private let expectedImage = UIImage(named: "Test", in: Bundle(for: AdvertisementItemCellViewTests.self), compatibleWith: nil)!
    private lazy var imageLoaderMock = ImageLoaderMock { url, _, completion in
        completion(url, url == self.expectedImageURL ? self.expectedImage : nil)
        return EmptyTask()
    }

    private lazy var cell: AdvertisementItemCellView = {
        let cell: AdvertisementItemCellView = view(nibName: "AdvertisementItemView", size: defaultSize)
        cell.imageLoader = imageLoaderMock
        return cell
    }()
    
    func testLoadedImageAppearance() {
        let cell = self.cell
        cell.display(item: AdvertisementItem(image: expectedImageURL))
        snapshotVerifyView(cell)
    }
    
    func testLoadingImageFailedAppearance() {
        let cell = self.cell
        cell.display(item: AdvertisementItem(image: URL(string: UUID().uuidString)!))
        snapshotVerifyView(cell)
    }

}
