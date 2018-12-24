//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import XCTest
@testable import RealEstate

final class ImageLoaderTests: XCTestCase {

    private let placeholderImage = UIImage(named: "Placeholder", in: Bundle(for: ImageLoaderTests.self), compatibleWith: nil)!
    private let expectedImage = UIImage(named: "Test", in: Bundle(for: ImageLoaderTests.self), compatibleWith: nil)!

    func testCachedImage() {
        let completionExpectation = self.expectation(description: "ImageLoader.image - completionHandler")
        
        let cache = NSCache<NSURL, UIImage>()
        let imageURL = URL(string: UUID().uuidString)!
        let sessionMock = URLSessionMock { _, _ in XCTFail("Should not be called in this test"); fatalError() }

        let loader = ImageLoader(
            urlSession: sessionMock,
            cache: cache
        )

        cache.setObject(expectedImage, forKey: imageURL as NSURL)
        
        loader.image(
            with: imageURL,
            loadingHandler: { _ in XCTFail("Should not be called in this test") },
            completionHandler: { url, image in
                XCTAssertEqual(url, imageURL)
                XCTAssertEqual(image?.pngData()!, self.expectedImage.pngData()!)
                completionExpectation.fulfill()
            }
        )
        
        wait(for: [completionExpectation], timeout: 1)
    }

    func testLoadedImage() {
        let expectedImageData = expectedImage.pngData()!
        let image = loadImage(data: .success(expectedImageData))
        XCTAssertEqual(image?.pngData()!, expectedImageData)
    }

    func testLoadingImageFailed() {
        let image = loadImage(data: .failure(MockError.some))
        XCTAssertNil(image)
    }

    func testLoadedImageOnImageView() {
        let expectedImageData = expectedImage.pngData()!
        let imageView = setImageOnImageView(data: .success(expectedImageData), placeholder: nil)
        XCTAssertEqual(imageView.image!.pngData()!, expectedImageData)
    }

    func testLoadingImageFailedOnImageViewWithPlaceholder() {
        let expectedImageData = placeholderImage.pngData()!
        let imageView = setImageOnImageView(data: .failure(MockError.some), placeholder: placeholderImage)
        XCTAssertEqual(imageView.image!.pngData()!, expectedImageData)
    }

    func testLoadingImageFailedOnImageViewWithoutPlaceholder() {
        let imageView = setImageOnImageView(data: .failure(MockError.some), placeholder: nil)
        XCTAssertNil(imageView.image)
    }

}

extension ImageLoaderTests {
    
    private enum MockError: Error { case some }
    
    private func loadImage<T>(data: Result<Data>, handler: (ImageLoader, URL) -> T) -> T {
        let sessionExpectation = self.expectation(description: "URLSession.dataTask")
        
        let cache = NSCache<NSURL, UIImage>()
        let imageURL = URL(string: UUID().uuidString)!
        let sessionMock = mockedSession(
            expectedURL: imageURL,
            resultStatusCode: data.value != nil ? 200 : 500,
            result: data,
            expectation: sessionExpectation
        )
        
        let loader = ImageLoader(
            urlSession: sessionMock,
            cache: cache
        )
        
        let result = handler(loader, imageURL)
        wait(for: [sessionExpectation], timeout: 1)
        
        return result
    }
    
    private func loadImage(data: Result<Data>) -> UIImage? {
        return loadImage(data: data) { loader, imageURL in
            let loadingExpectation = self.expectation(description: "ImageLoader.image - loadingHandler")
            let completionExpectation = self.expectation(description: "ImageLoader.image - completionHandler")

            var result: UIImage?
            loader.image(
                with: imageURL,
                loadingHandler: { url in
                    XCTAssertEqual(url, imageURL)
                    loadingExpectation.fulfill()
                },
                completionHandler: { url, image in
                    XCTAssertEqual(url, imageURL)
                    result = image
                    completionExpectation.fulfill()
                }
            )
            
            wait(for: [loadingExpectation, completionExpectation], timeout: 1)
            return result
        }
    }
    
    private func setImageOnImageView(data: Result<Data>, placeholder: UIImage?) -> UIImageView {
        let imageView: UIImageView = loadImage(data: data) { loader, imageURL in
            let imageView = UIImageView()
            loader.setImage(with: imageURL, on: imageView, placeholder: placeholder)
            return imageView
        }
        
        // Have to postpone the return since an image is set on the image view on the main thread asynchronously
        let expectation = self.expectation(description: "")
        OperationQueue.main.addOperation { expectation.fulfill() }
        wait(for: [expectation], timeout: 1)

        return imageView
    }

}
