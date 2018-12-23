//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import Foundation

protocol AdvertisementsGatewayProtocol {
    
    @discardableResult
    func loadAll(completion handler: @escaping (Result<[URL]>) -> Void) -> Cancellable

}

final class AdvertisementsGateway: AdvertisementsGatewayProtocol {
    
    private static let advertisements = [
        URL(string: "https://farname.ir/upload/posts/1397-06/best_Advertisement_farname.jpg")!,
        URL(string: "https://stepcommunications.com.bd/wp-content/uploads/2016/04/advertising-design.jpg")!,
        URL(string: "https://www.bucurestitv.net/wp-content/uploads/2016/01/publicitate.jpg")!,
        URL(string: "https://www.odishapolice.gov.in/sites/default/files/opImages/ADVERTISEMENT%20.jpg")!,
        URL(string: "https://www.sapo.vn/blog/wp-content/uploads/2016/05/quang-cao-online.png")!,
    ]
    
    private let queue = OperationQueue()
    
    func loadAll(completion handler: @escaping (Result<[URL]>) -> Void) -> Cancellable {
        queue.addOperation {
            handler(.success(AdvertisementsGateway.advertisements.shuffled()))
        }
        return EmptyTask()
    }
    

}
