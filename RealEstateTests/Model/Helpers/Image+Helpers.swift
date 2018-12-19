//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import Foundation
@testable import RealEstate

extension Image {
    
    static func random() -> Image {
        return Image(
            id: Int.random(in: 1...Int.max),
            url: URL(string: UUID().uuidString)!
        )
    }
    
}

extension Image: JSONPresentable {
    
    func JSON() -> [String: Any] {
        return [
            "id": id,
            "url": url.absoluteString
        ]
    }

}
