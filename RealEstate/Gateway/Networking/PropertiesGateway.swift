//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import Foundation

extension URLSessionDataTask: Cancellable { }

enum PropertiesGatewayError: Error {
    
    case unknwon
    
}

protocol PropertiesGatewayProtocol {
    
    @discardableResult
    func loadAll(completion handler: @escaping (Result<[Property]>) -> Void) -> Cancellable
    
}

final class PropertiesGateway: PropertiesGatewayProtocol {
    
    private let urlSession: URLSessionProtocol
    private let jsonDecoder: JSONDecoderProtocol
    
    private var urlRequest: URLRequest {
        return URLRequest(url: URL(string: "https://private-91146-mobiletask.apiary-mock.com/realestates")!)
    }
    
    init(urlSession: URLSessionProtocol = URLSession.shared, jsonDecoder: JSONDecoderProtocol = JSONDecoder()) {
        self.urlSession = urlSession
        self.jsonDecoder = jsonDecoder
    }
    
    @discardableResult
    func loadAll(completion handler: @escaping (Result<[Property]>) -> Void) -> Cancellable {
        let jsonDecoder = self.jsonDecoder
        let task = urlSession.dataTask(with: urlRequest) { (data, response, error) in
            guard let data = data, let response = response as? HTTPURLResponse, (200..<300).contains(response.statusCode) else {
                handler(.failure(error ?? PropertiesGatewayError.unknwon))
                return
            }

            do {
                let properties = try jsonDecoder.decode(PropertiesResponse.self, from: data)
                handler(.success(properties.items))
            } catch let decodingError {
                handler(.failure(decodingError))
            }
        }

        task.resume()
        return task
    }
}
