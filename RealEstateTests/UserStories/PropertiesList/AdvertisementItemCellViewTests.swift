//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import XCTest
@testable import RealEstate

class AdvertisementItemCellViewTests: XCTestCase {

    private let defaultBounds = CGRect(x: 0, y: 0, width: 350, height: 250)
    
    private let expectedImageURL = URL(string: UUID().uuidString)!
    private let expectedImage = UIImage(named: "Test", in: Bundle(for: AdvertisementItemCellViewTests.self), compatibleWith: nil)!
    private lazy var imageLoaderMock = ImageLoaderMock { url, _, completion in
        completion(url, url == self.expectedImageURL ? self.expectedImage : nil)
        return EmptyTask()
    }

    private lazy var cell: AdvertisementItemCellView = {
        let bundle = Bundle(for: AdvertisementItemCellView.self)
        let storyboard = UIStoryboard(name: "Main", bundle: bundle)
        let controller = storyboard.instantiateViewController(withIdentifier: "PropertiesListCollectionViewController") as! UICollectionViewController
        let cell = controller.collectionView.dequeueReusableCell(withReuseIdentifier: "AdvertisementItem", for: IndexPath(item: 0, section: 0)) as! AdvertisementItemCellView
        cell.frame = defaultBounds
        cell.contentView.frame = defaultBounds
        cell.imageLoader = imageLoaderMock
        return cell
    }()
    
    func testLoadedImageAppearance() {
        let cell = self.cell
        cell.display(item: AdvertisementItem(image: expectedImageURL))
        snapshotVerifyView(cell.contentView)
    }
    
    func testLoadingImageFailedAppearance() {
        let cell = self.cell
        cell.display(item: AdvertisementItem(image: URL(string: UUID().uuidString)!))
        snapshotVerifyView(cell.contentView)
    }

}
