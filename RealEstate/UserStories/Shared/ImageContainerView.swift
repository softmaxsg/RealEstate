//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import UIKit

protocol ImageContainerView: class {
    
    var imageLoader: ImageLoaderProtocol { get }
    var currentImageLoaderTask: Cancellable? { get set }
    var imageView: UIImageView? { get }
    
}

extension ImageContainerView {
    
    func clearImageView() {
        if let currentImageLoaderTask = currentImageLoaderTask, let imageView = imageView {
            self.currentImageLoaderTask = nil
            imageLoader.cancel(task: currentImageLoaderTask, on: imageView)
        }
        
        imageView?.image = nil
    }
    
    func displayImage(with url: URL, placeholder placeHolderImage: UIImage? = nil) {
        guard let imageView = imageView else { assertionFailure(); return }
        currentImageLoaderTask = imageLoader.setImage(with: url, on: imageView, placeholder: placeHolderImage)
    }
    
}
