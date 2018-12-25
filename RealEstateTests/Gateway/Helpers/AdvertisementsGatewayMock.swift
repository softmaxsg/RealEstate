//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import Foundation
@testable import RealEstate

final class AdvertisementsGatewayMock: AdvertisementsGatewayProtocol {
    
    typealias LoadAllImpl = (@escaping (Result<[URL]>) -> Void) -> Cancellable
    
    private let loadAllImpl: LoadAllImpl
    
    init(loadAll: @escaping LoadAllImpl) {
        self.loadAllImpl = loadAll
    }
    
    @discardableResult
    func loadAll(completion handler: @escaping (Result<[URL]>) -> Void) -> Cancellable {
        return loadAllImpl(handler)
    }
    
}
