//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import Foundation

enum Result<Value> {

    case success(Value)
    case failure(Error)
    
}

extension Result {

    public init(value: Value) {
        self = .success(value)
    }
    
    public init(error: Error) {
        self = .failure(error)
    }

}
