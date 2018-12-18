//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import Foundation

struct Location: Equatable, Decodable {
    
    struct Coordinate: Equatable {
        
        let latitude: Double
        let longitude: Double
        
    }

    let address: String
    let coordinate: Coordinate
    
    init(address: String, coordinate: Coordinate) {
        self.address = address
        self.coordinate = coordinate
    }

    init(from decoder: Decoder) throws {
        fatalError()
    }

}
