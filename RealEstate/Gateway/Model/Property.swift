//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import Foundation

struct Property: Equatable {
    
    let id: Int
    let title: String
    let price: Decimal
    let location: Location
    let images: [Image]
}

extension Property: Decodable {

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case price
        case location
        case images
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        title = try values.decode(String.self, forKey: .title)
        price = try values.decode(Decimal.self, forKey: .price)
        location = try values.decode(Location.self, forKey: .location)
        images = (try? values.decode([Image].self, forKey: .images)) ?? []
    }

}

extension Property: Encodable { }
