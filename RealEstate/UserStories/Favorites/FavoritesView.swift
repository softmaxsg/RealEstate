//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import UIKit

final class FavoritesCollectionViewController: UICollectionViewController {

    @IBOutlet weak var emptyBackgroundView: UIView?

    private enum ReuseIdentifier: String {
        
        case propertyItem = "PropertyItem"
        
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        collectionView.backgroundView = emptyBackgroundView
        return 0
    }

}
