//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import Foundation

protocol PropertyListItemViewProtocol {
    
    associatedtype ItemType: PropertyListItem
    
    func display(item: ItemType)
    
}
