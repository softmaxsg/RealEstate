//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import UIKit

protocol PropertyItemViewProtocol {

    func display(item: PropertyItem)
    
}

final class PropertyItemCellView: UICollectionViewCell {
    
    private static let placeHolderImage = "ImagePlaceholder"
    
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
        imageView?.image = UIImage(named: PropertyItemCellView.placeHolderImage)
        titleLabel?.text = item.title
        addressLabel?.text = item.address
        priceLabel?.text = item.price
    }

}

extension PropertyItemCellView {
    
    private func clear() {
        imageView?.image = nil
        titleLabel?.text = ""
        addressLabel?.text = ""
        priceLabel?.text = ""
    }
    
}
