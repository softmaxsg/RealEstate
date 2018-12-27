//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import Foundation

protocol AdvertisementsEmbedderProtocol {

    func embed(_ advertisements: [URL], into properties: [Property]) -> [PropertyListItemInfo]
    
}

final class AdvertisementsEmbedder: AdvertisementsEmbedderProtocol {
    
    func embed(_ advertisements: [URL], into properties: [Property]) -> [PropertyListItemInfo] {
        var result: [PropertyListItemInfo] = []
        
        var currentAdIndex = advertisements.startIndex
        for (index, property) in properties.enumerated() {
            if index > 0 && index % 2 == 0 {
                if currentAdIndex < advertisements.endIndex {
                    result.append(.advertisement(advertisements[currentAdIndex]))
                    
                    advertisements.formIndex(after: &currentAdIndex)
                    if currentAdIndex == advertisements.endIndex {
                        currentAdIndex = advertisements.startIndex
                    }
                }
            }
            
            result.append(.property(property))
        }
        
        return result
    }
    
}
