//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import UIKit

protocol AdvertisementItemViewProtocol: PropertyListItemViewProtocol {

    func display(item: AdvertisementItem)
    
}

final class AdvertisementItemCellView: UICollectionViewCell {
    
    private lazy var placeHolderImage = UIImage(named: "ImagePlaceholder")
    
    var imageLoader: ImageLoader?
    
    private var currentImageLoaderTask: Cancellable?
    
    @IBOutlet weak var imageView: UIImageView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.clear()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.clear()
    }
    
}

extension AdvertisementItemCellView: AdvertisementItemViewProtocol {
    
    func display(item: AdvertisementItem) {
        guard let imageLoader = imageLoader, let imageView = imageView else { assertionFailure(); return }
        currentImageLoaderTask = imageLoader.setImage(with: item.image, on: imageView, placeholder: placeHolderImage)
    }
    
}

extension AdvertisementItemCellView {
    
    private func clear() {
        if let currentImageLoaderTask = currentImageLoaderTask, let imageView = imageView {
            self.currentImageLoaderTask = nil
            imageLoader?.cancel(task: currentImageLoaderTask, on: imageView)
        }

        imageView?.image = nil
    }

}
