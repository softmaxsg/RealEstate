//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import UIKit

protocol CollectionViewCellAdjuster {
    
    var collectionView: UICollectionView! { get }
    
    func adjustCellSize(for size: CGSize, safeArea: UIEdgeInsets)
    func adjustCellSizeInTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator)
    
}

extension CollectionViewCellAdjuster {
    
    func adjustCellSize(for size: CGSize, safeArea: UIEdgeInsets) {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { assertionFailure(); return }
        
        let viewWidth = size.width - (safeArea.left + safeArea.right)
        let columnsCount = CGFloat(Int(viewWidth) / 500 + 1)
        let spacing: CGFloat = (viewWidth / columnsCount) < 350 ? 10 : 20
        
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        layout.itemSize = CGSize(
            width: (viewWidth - spacing * (columnsCount + 1)) / columnsCount,
            height: 250
        )
    }
    
    func adjustCellSizeInTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.collectionViewLayout.invalidateLayout()
        
        coordinator.animate(
            alongsideTransition: { _ in
                self.adjustCellSize(for: size, safeArea: self.collectionView.safeAreaInsets)
            },
            completion: { _ in
                self.collectionView.collectionViewLayout.invalidateLayout()
            }
        )
    }
    
}
