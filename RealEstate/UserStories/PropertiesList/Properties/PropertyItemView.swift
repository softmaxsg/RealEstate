//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import UIKit

protocol PropertyItemViewProtocol: PropertyListItemViewProtocol {

    func display(item: PropertyItem)
    
}

final class PropertyItemCellView: UICollectionViewCell {
    
    private lazy var placeHolderImage = UIImage(named: "ImagePlaceholder")
    
    var imageLoader: ImageLoader?
    
    private var currentImageURL: URL?
    private var currentImageLoaderTask: Cancellable?
    
    @IBOutlet weak var imageView: UIImageView?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var addressLabel: UILabel?
    @IBOutlet weak var priceLabel: UILabel?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.clear()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.clear()
    }

}

extension PropertyItemCellView: PropertyItemViewProtocol {

    func display(item: PropertyItem) {
        currentImageURL = item.image
        
        titleLabel?.text = item.title
        addressLabel?.text = item.address
        priceLabel?.text = item.price

        if let imageURL = item.image, let imageLoader = self.imageLoader {
            currentImageLoaderTask = imageLoader.image(
                with: imageURL,
                loadingHandler: { [weak self] url in self?.updateImage(nil, for: url) },
                completionHandler: { [weak self] url, image in self?.updateImage(image, for: url) }
            )
        } else {
            imageView?.image = placeHolderImage
        }
        
    }

}

extension PropertyItemCellView {
    
    private func clear() {
        currentImageURL = nil
        currentImageLoaderTask?.cancel()

        imageView?.image = nil
        titleLabel?.text = ""
        addressLabel?.text = ""
        priceLabel?.text = ""
    }

    private func updateImage(_ image: UIImage?, for url: URL) {
        if url == currentImageURL {
            imageView?.image = image ?? placeHolderImage
        }
    }
}
