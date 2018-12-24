//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import Foundation
@testable import RealEstate

final class AdvertisementsEmbedderMock: AdvertisementsEmbedderProtocol {

    typealias EmbedImpl = ([AdvertisementItem], [PropertyItem]) -> [PropertyListItemInfo]
    
    private let embedImpl: EmbedImpl

    init(embedImpl: @escaping EmbedImpl) {
        self.embedImpl = embedImpl
    }

    func embed(_ advertisements: [AdvertisementItem], into properties: [PropertyItem]) -> [PropertyListItemInfo] {
        return embedImpl(advertisements, properties)
    }
    
}
