//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import Foundation
@testable import RealEstate

final class AdvertisementsEmbedderMock: AdvertisementsEmbedderProtocol {

    typealias EmbedImpl = ([URL], [Property]) -> [PropertyListItemInfo]
    
    private let embedImpl: EmbedImpl

    init(embedImpl: @escaping EmbedImpl) {
        self.embedImpl = embedImpl
    }

    func embed(_ advertisements: [URL], into properties: [Property]) -> [PropertyListItemInfo] {
        return embedImpl(advertisements, properties)
    }
    
}
