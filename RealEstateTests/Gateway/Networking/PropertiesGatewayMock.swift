//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import Foundation
@testable import RealEstate

final class PropertiesGatewayMock: PropertiesGatewayProtocol {

    typealias LoadAllImpl = (@escaping (Result<[Property]>) -> Void) -> Cancellable
    
    private let loadAllImpl: LoadAllImpl
    
    init(loadAll: @escaping LoadAllImpl) {
        self.loadAllImpl = loadAll
    }

    @discardableResult
    func loadAll(completion handler: @escaping (Result<[Property]>) -> Void) -> Cancellable {
        return loadAllImpl(handler)
    }
    
}
