//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import Foundation

struct Location: Equatable {
    
    struct Coordinate: Equatable {
        
        let latitude: Double
        let longitude: Double
        
    }

    let address: String
    let coordinate: Coordinate

}

extension Location: Decodable {

    enum CodingKeys: String, CodingKey {
        case address
        case latitude
        case longitude
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        address = try values.decode(String.self, forKey: .address)
        coordinate = Coordinate(
            latitude: try values.decode(Double.self, forKey: .latitude),
            longitude: try values.decode(Double.self, forKey: .longitude)
        )
    }

}
