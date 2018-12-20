//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import Foundation

extension Dictionary {
    
    public func removingValue(forKey key: Key) -> [Key: Value] {
        var result = self
        result.removeValue(forKey: key)
        return result
    }
    
}
