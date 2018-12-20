//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import Foundation
@testable import RealEstate

final class URLSessionDataTaskMock: URLSessionDataTaskProtocol {
    
    typealias MethodImpl = () -> Void
    
    private let resumeImpl: MethodImpl
    private let cancelImpl: MethodImpl
    
    init(resume: @escaping MethodImpl, cancel: @escaping MethodImpl) {
        self.resumeImpl = resume
        self.cancelImpl = cancel
    }
    
    func resume() {
        resumeImpl()
    }
    
    func cancel() {
        cancelImpl()
    }
    
}
