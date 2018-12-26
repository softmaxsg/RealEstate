//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import UIKit

protocol PropertyItemViewProtocol: PropertyListItemViewProtocol {

    typealias Callback = () -> Void
    
    var favoriteButtonCallback: Callback? { get set }
    func display(item: PropertyItem)
    
}

final class PropertyItemCellView: UICollectionViewCell, ImageContainerView {
    
    private lazy var placeHolderImage = UIImage(named: "ImagePlaceholder")
    
    var favoriteButtonCallback: Callback?

    var imageLoader: ImageLoaderProtocol = DependencyContainer.shared.imageLoader
    var currentImageLoaderTask: Cancellable?
    
    @IBOutlet weak var imageView: UIImageView?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var addressLabel: UILabel?
    @IBOutlet weak var priceLabel: UILabel?
    @IBOutlet weak var favoriteButton: UIButton?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.clear()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.clear()
    }

    @IBAction func favoriteButtonDidTap() {
        favoriteButtonCallback?()
    }
    
}

extension PropertyItemCellView: PropertyItemViewProtocol {

    func display(item: PropertyItem) {
        assert(titleLabel != nil)
        assert(addressLabel != nil)
        assert(priceLabel != nil)
        // favoriteButton is not asserted since it's not required

        titleLabel?.text = item.title
        addressLabel?.text = item.address
        priceLabel?.text = item.price
        favoriteButton?.isSelected = item.isFavorite

        if let imageURL = item.image {
            displayImage(with: imageURL, placeholder: placeHolderImage)
        } else {
            imageView?.image = placeHolderImage
        }
    }

}

extension PropertyItemCellView {
    
    private func clear() {
        clearImageView()

        titleLabel?.text = ""
        addressLabel?.text = ""
        priceLabel?.text = ""
    }

}
