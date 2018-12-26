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

extension Location: Codable {

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
    
    func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try values.encode(address, forKey: .address)
        try values.encode(coordinate.latitude, forKey: .latitude)
        try values.encode(coordinate.longitude, forKey: .longitude)
    }

}
