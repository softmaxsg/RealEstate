//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import Foundation
@testable import RealEstate

final class JSONDecoderMock<T: Decodable>: JSONDecoderProtocol {
    
    typealias DecodeImpl = (Data) throws -> T
    
    private let decodeImpl: DecodeImpl
    
    init(decodeImpl: @escaping DecodeImpl) {
        self.decodeImpl = decodeImpl
    }
    
    func decode<U>(_ type: U.Type, from data: Data) throws -> U where U: Decodable {
        assert(T.self == U.self)
        return try decodeImpl(data) as! U
    }
    
}
