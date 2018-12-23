//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import Foundation

protocol Cancellable {
    
    func cancel()
    
}

class EmptyTask: Cancellable {

    func cancel() { }

}

extension URLSessionDataTask: Cancellable { }
