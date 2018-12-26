//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import UIKit

protocol FavoritesViewProtocol: class {
    
    func updateView()
    
}

final class FavoritesCollectionViewController: UICollectionViewController, CollectionViewCellAdjuster {

    @IBOutlet weak var emptyBackgroundView: UIView?

    private enum ReuseIdentifier: String {
        
        case propertyItem = "PropertyItem"
        
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        collectionView.backgroundView = emptyBackgroundView
        return 0
    }

}
