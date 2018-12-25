//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import XCTest

extension XCTestCase {
    
    func collectionView<T>(storyboardID: String, controllerID: String, cellID: String, size: CGSize) -> T where T: UICollectionViewCell {
        let bundle = Bundle(for: T.self)
        let storyboard = UIStoryboard(name: storyboardID, bundle: bundle)
        let controller = storyboard.instantiateViewController(withIdentifier: controllerID) as! UICollectionViewController
        let cell = controller.collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: IndexPath(item: 0, section: 0)) as! T
        
        let bounds = CGRect(origin: .zero, size: size)
        cell.frame = bounds
        cell.contentView.frame = bounds
        
        return cell
    }
    
}
