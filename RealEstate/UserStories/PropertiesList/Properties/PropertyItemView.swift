//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import UIKit

protocol PropertyItemViewProtocol: PropertyListItemViewProtocol {

    func display(item: PropertyItem)
    
}

final class PropertyItemCellView: UICollectionViewCell {
    
    private lazy var placeHolderImage = UIImage(named: "ImagePlaceholder")
    
    var imageLoader: ImageLoaderProtocol?
    
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
        guard let imageLoader = imageLoader, let imageView = imageView else { assertionFailure(); return }

        assert(titleLabel != nil)
        assert(addressLabel != nil)
        assert(priceLabel != nil)

        titleLabel?.text = item.title
        addressLabel?.text = item.address
        priceLabel?.text = item.price

        if let imageURL = item.image {
            currentImageLoaderTask = imageLoader.setImage(with: imageURL, on: imageView, placeholder: placeHolderImage)
        } else {
            imageView.image = placeHolderImage
        }
        
    }

}

extension PropertyItemCellView {
    
    private func clear() {
        if let currentImageLoaderTask = currentImageLoaderTask, let imageView = imageView {
            self.currentImageLoaderTask = nil
            imageLoader?.cancel(task: currentImageLoaderTask, on: imageView)
        }

        imageView?.image = nil
        titleLabel?.text = ""
        addressLabel?.text = ""
        priceLabel?.text = ""
    }

}
