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
    
    private static let alternativeImages = [
        URL(string: "https://pictureis24-a.akamaihd.net/pic/orig01/N/278/959/428/278959428-0.jpg/ORIG/resize/600x400/format/jpg")!: URL(string: "https://pictures.immobilienscout24.de/listings/79bc7715-cbc2-4a37-baf3-6100b4803bae-1261100121.png/ORIG/legacy_thumbnail/532x399/format/jpg/quality/80")!,
        URL(string: "https://pictureis24-a.akamaihd.net/pic/orig04/N/278/958/547/278958547-0.jpg/ORIG/resize/600x400/format/jpg")!: URL(string: "https://pictures.immobilienscout24.de/listings/509e1e28-2542-49e1-8119-f5cf8b8c65ed-1257985633.jpg/ORIG/legacy_thumbnail/532x399/format/jpg/quality/80")!,
        URL(string: "https://pictureis24-a.akamaihd.net/pic/orig02/N/278/957/321/278957321-0.jpg/ORIG/resize/600x400/format/jpg")!: URL(string: "https://pictures.immobilienscout24.de/listings/c1eaa091-62b3-44df-9337-f34fe6261b31-1261013544.jpg/ORIG/legacy_thumbnail/532x399/format/jpg/quality/80")!,
        URL(string: "https://pictureis24-a.akamaihd.net/pic/orig01/N/278/948/784/278948784-0.jpg/ORIG/resize/600x400/format/jpg")!: URL(string: "https://pictures.immobilienscout24.de/dims3/S3/legacy_thumbnail/532x399/format/jpg/quality/80/http://s3-eu-west-1.amazonaws.com/pda-pro-pictures-projectpictures-8hecgpgpb9fo/89803732/96dcd7e8-3149-4a8a-8f4d-9862e610db0e.jpg")!,
        URL(string: "https://pictureis24-a.akamaihd.net/pic/orig04/N/278/945/963/278945963-0.jpg/ORIG/resize/600x400/format/jpg")!: URL(string: "https://pictures.immobilienscout24.de/listings/647c8beb-5ab5-46cb-b4cd-66f4142bdfb8-1257815534.jpg/ORIG/legacy_thumbnail/532x399/format/jpg/quality/80")!,
        URL(string: "https://pictureis24-a.akamaihd.net/pic/orig02/N/278/941/873/278941873-0.jpg/ORIG/resize/600x400/format/jpg")!: URL(string: "https://pictures.immobilienscout24.de/listings/d7754377-8d6d-4d94-ab18-724ec0c8d24e-1252892971.jpg/ORIG/legacy_thumbnail/532x399/format/jpg/quality/80")!,
        URL(string: "https://pictureis24-a.akamaihd.net/pic/orig03/N/278/929/206/278929206-0.jpg/ORIG/resize/600x400/format/jpg")!: URL(string: "https://pictures.immobilienscout24.de/listings/df3899ca-107a-44ed-9bcb-f73491c24a9a-1227005922.jpg/ORIG/legacy_thumbnail/532x399/format/jpg/quality/80")!,
        URL(string: "https://pictureis24-a.akamaihd.net/pic/orig03/N/278/920/198/278920198-0.jpg/ORIG/resize/600x400/format/jpg")!: URL(string: "https://pictures.immobilienscout24.de/dims3/S3/legacy_thumbnail/532x399/format/jpg/quality/80/http://s3-eu-west-1.amazonaws.com/pda-pro-pictures-projectpictures-8hecgpgpb9fo/87335983/fd2a62be-fa03-4f67-a67f-21068ad2c13d.jpg")!,
        URL(string: "https://pictureis24-a.akamaihd.net/pic/orig03/N/277/752/662/277752662-0.jpg/ORIG/resize/600x400/format/jpg")!: URL(string: "https://pictures.immobilienscout24.de/listings/9ddfa1ff-ac44-4131-b008-0f620a37006f-1261414884.jpg/ORIG/legacy_thumbnail/532x399/format/jpg/quality/80")!,
        URL(string: "https://pictureis24-a.akamaihd.net/pic/orig03/N/277/499/734/277499734-0.jpg/ORIG/resize/600x400/format/jpg")!: URL(string: "https://pictures.immobilienscout24.de/listings/7f6441c2-6c46-4898-8882-1ea0144501a7-1256416980.jpg/ORIG/legacy_thumbnail/532x399/format/jpg/quality/80")!,
    ]
    
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
        
        let task = urlSession.dataTask(with: URLRequest(url: ImageLoader.alternativeImages[url] ?? url)) { [weak self] data, _, _ in
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
