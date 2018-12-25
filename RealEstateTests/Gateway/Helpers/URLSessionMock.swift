//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import Foundation
@testable import RealEstate

final class URLSessionMock: URLSessionProtocol {
    
    typealias DataTaskImpl = (URLRequest, @escaping DataTaskHandler) -> URLSessionDataTaskProtocol
    
    private let dataTaskImpl: DataTaskImpl
    
    init(dataTask: @escaping DataTaskImpl) {
        self.dataTaskImpl = dataTask
    }
    
    func dataTask(with request: URLRequest, completionHandler: @escaping DataTaskHandler) -> URLSessionDataTaskProtocol {
        return dataTaskImpl(request, completionHandler)
    }
    
}
