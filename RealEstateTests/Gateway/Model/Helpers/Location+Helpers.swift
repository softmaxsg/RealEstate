//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import Foundation
@testable import RealEstate

extension Location {
    
    static func random() -> Location {
        return Location(
            address: UUID().uuidString,
            coordinate: Location.Coordinate(
                latitude: Double.random(in: -180...180),
                longitude: Double.random(in: -180...180)
            )
        )
    }
    
}

extension Location: JSONPresentable {

    func JSON() -> [String: Any] {
        return [
            "address": address,
            "latitude": coordinate.latitude,
            "longitude": coordinate.longitude
        ]
    }
    
}
