//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import UIKit
import ObjectiveC

protocol ImageLoaderProtocol {
    
    typealias LoadingHandler = (URL) -> Void
    typealias CompletionHandler = (URL, UIImage?) -> Void
    
    @discardableResult
    func image(with url: URL, loadingHandler: @escaping LoadingHandler, completionHandler: @escaping CompletionHandler) -> Cancellable

    @discardableResult
    func setImage(with url: URL, on imageView: UIImageView, placeholder: UIImage?) -> Cancellable

    func cancel(task: Cancellable, on imageView: UIImageView)

}

final class ImageLoader: ImageLoaderProtocol {
    
    private let urlSession: URLSessionProtocol
    private let cache: NSCache<NSURL, UIImage>

    init(urlSession: URLSessionProtocol = URLSession.shared, cache: NSCache<NSURL, UIImage> = NSCache<NSURL, UIImage>()) {
        self.urlSession = urlSession
        self.cache = cache
    }
    
    @discardableResult
    func image(with url: URL, loadingHandler: @escaping LoadingHandler, completionHandler: @escaping CompletionHandler) -> Cancellable {
        if let cachedImage = cache.object(forKey: url as NSURL) {
            completionHandler(url, cachedImage)
            return EmptyTask()
        }
        
        loadingHandler(url)
        
        let task = urlSession.dataTask(with: URLRequest(url: url)) { [weak self] data, _, _ in
            let image: UIImage?
            
            if let data = data {
                image = UIImage(data: data)
                if let image = image {
                    self?.cache.setObject(image, forKey: url as NSURL)
                }
            } else {
                image = nil
            }
            
            OperationQueue.main.addOperation {
                completionHandler(url, image)
            }
        }
        
        task.resume()
        return task
    }

}

extension ImageLoaderProtocol {
    
    @discardableResult
    func setImage(with url: URL, on imageView: UIImageView, placeholder: UIImage?) -> Cancellable {
        imageView.currentURL = url
        return image(
            with: url,
            loadingHandler: { url in imageView.setImage(nil, from: url, placeholder: placeholder) },
            completionHandler: { url, image in imageView.setImage(image, from: url, placeholder: placeholder) }
        )
    }
    
    func cancel(task: Cancellable, on imageView: UIImageView) {
        imageView.currentURL = nil
        task.cancel()
    }

}


extension UIImageView {
    
    private static var associatedURLKey: UInt = 0
    
    fileprivate var currentURL: URL? {
        get {
            return objc_getAssociatedObject(self, &UIImageView.associatedURLKey) as? URL
        }
        
        set {
            objc_setAssociatedObject(self, &UIImageView.associatedURLKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    fileprivate func setImage(_ image: UIImage?, from url: URL, placeholder: UIImage?) {
        if url == currentURL {
            self.image = image ?? placeholder
        }
    }
    
}
