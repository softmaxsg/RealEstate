//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import UIKit

final class ImageLoader {
    
    private let urlSession: URLSessionProtocol
    private let cache: NSCache<NSURL, UIImage>

    init(urlSession: URLSessionProtocol = URLSession.shared, cache: NSCache<NSURL, UIImage> = NSCache<NSURL, UIImage>()) {
        self.urlSession = urlSession
        self.cache = cache
    }
    
    @discardableResult
    func image(with url: URL, loadingHandler: @escaping (URL) -> Void, completionHandler: @escaping (URL, UIImage?) -> Void) -> Cancellable {
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
