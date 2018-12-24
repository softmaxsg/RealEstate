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
    
    private var currentImageURL: URL?
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
        currentImageURL = item.image
        
        if let imageLoader = self.imageLoader {
            currentImageLoaderTask = imageLoader.image(
                with: item.image,
                loadingHandler: { [weak self] url in self?.updateImage(nil, for: url) },
                completionHandler: { [weak self] url, image in self?.updateImage(image, for: url) }
            )
        } else {
            imageView?.image = placeHolderImage
        }
        
    }
    
}

extension AdvertisementItemCellView {
    
    private func clear() {
        currentImageURL = nil
        currentImageLoaderTask?.cancel()
        imageView?.image = nil
    }
    
    private func updateImage(_ image: UIImage?, for url: URL) {
        if url == currentImageURL {
            imageView?.image = image ?? placeHolderImage
        }
    }
}
