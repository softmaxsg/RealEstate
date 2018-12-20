//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import Foundation

protocol URLSessionProtocol {
    
    typealias DataTaskHandler = (Data?, URLResponse?, Error?) -> Void
    
    func dataTask(with request: URLRequest, completionHandler: @escaping DataTaskHandler) -> URLSessionDataTaskProtocol
}

extension URLSession: URLSessionProtocol {

    // Required just to allow using URLSessionDataTaskProtocol as a return type
    func dataTask(with request: URLRequest, completionHandler: @escaping DataTaskHandler) -> URLSessionDataTaskProtocol {
        return dataTask(with: request, completionHandler: completionHandler) as URLSessionDataTask
    }
    
}
