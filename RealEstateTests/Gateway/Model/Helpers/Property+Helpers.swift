//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import Foundation
@testable import RealEstate

extension Property {
    
    static func random() -> Property {
        return Property(
            id: PropertyID.random(in: 1...PropertyID.max),
            title: UUID().uuidString,
            price: Decimal(Int.random(in: 1...Int.max)),
            location: Location.random(),
            images: Array(0...Int.random(in: 0...10)).map { _ in Image.random() }
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
