//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import Foundation

enum RandomAccessCollectionError: Error {
    
    case indexOutOfBounds
    
}

extension RandomAccessCollection {
    
    func item(at index: Index) throws -> Element {
        guard indices.contains(index) else { throw RandomAccessCollectionError.indexOutOfBounds }
        return self[index]
    }
    
}
