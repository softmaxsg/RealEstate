//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import UIKit

protocol AdvertisementItemViewProtocol: PropertyListItemViewProtocol {

    func display(item: AdvertisementItem)
    
}

final class AdvertisementItemCellView: UICollectionViewCell, ImageContainerView {
    
    private lazy var placeHolderImage = UIImage(named: "ImagePlaceholder")
    
    var imageLoader: ImageLoaderProtocol = DependencyContainer.shared.imageLoader
    var currentImageLoaderTask: Cancellable?
    
    @IBOutlet weak var imageView: UIImageView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        clearImageView()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        clearImageView()
    }
    
}

extension AdvertisementItemCellView: AdvertisementItemViewProtocol {
    
    func display(item: AdvertisementItem) {
        displayImage(with: item.image, placeholder: placeHolderImage)
    }
    
}

extension AdvertisementItemCellView {
    
    class func register(in collectionView: UICollectionView, with identifier: String) {
        collectionView.register(
            UINib(nibName: "AdvertisementItemView", bundle: nil),
            forCellWithReuseIdentifier: identifier
        )
    }
    
}
