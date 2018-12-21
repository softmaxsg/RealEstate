//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import XCTest
@testable import RealEstate

final class ImageLoaderTests: XCTestCase {

    private let expectedImage = UIImage(named: "Placeholder", in: Bundle(for: ImageLoaderTests.self), compatibleWith: nil)!
    
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

    func testLoadingFailedImage() {
        let image = loadImage(data: .failure(MockError.some))
        XCTAssertNil(image)
    }

}

extension ImageLoaderTests {
    
    private enum MockError: Error { case some }
    
    private func loadImage(data: Result<Data>) -> UIImage? {
        let sessionExpectation = self.expectation(description: "URLSession.dataTask")
        let loadingExpectation = self.expectation(description: "ImageLoader.image - loadingHandler")
        let completionExpectation = self.expectation(description: "ImageLoader.image - completionHandler")
        
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
        
        wait(for: [sessionExpectation, loadingExpectation, completionExpectation], timeout: 1)
        return result
    }
    
}
