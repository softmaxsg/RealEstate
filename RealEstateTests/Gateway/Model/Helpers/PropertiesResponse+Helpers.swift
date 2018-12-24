//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import Foundation
@testable import RealEstate

extension PropertiesResponse {
    
    static func random() -> PropertiesResponse {
        return PropertiesResponse(
            items: Array(0...Int.random(in: 0...10)).map { _ in Property.random() }
        )
    }
    
}

extension PropertiesResponse: JSONPresentable {
    
    func JSON() -> [String: Any] {
        return [
            "items": items.map { $0.JSON() }
        ]
    }
    
}
