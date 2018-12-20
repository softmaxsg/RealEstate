//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import Foundation
@testable import RealEstate

extension Property {
    
    static func random() -> Property {
        return Property(
            id: Int.random(in: 1...Int.max),
            title: UUID().uuidString,
            price: Decimal(Int.random(in: 1...Int.max)),
            location: Location.random(),
            images: Array(repeating: 0, count: Int.random(in: 1...10)).map { _ in Image.random() }
        )
    }

}

extension Property: JSONPresentable {

    func JSON() -> [String: Any] {
        return [
            "id": id,
            "title": title,
            "price": price,
            "location": location.JSON(),
            "images": images.map { $0.JSON() }
        ]
    }

}
