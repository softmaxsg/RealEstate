//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import XCTest

extension XCTestCase {

    func view<T>(nibName: String, size: CGSize? = nil) -> T where T: UIView {
        let bundle = Bundle(for: T.self)
        let nib = UINib(nibName: nibName, bundle: bundle)
        let view = nib.instantiate(withOwner: nil).compactMap({ $0 as? T }).first!
        
        if let size = size {
            let bounds = CGRect(origin: .zero, size: size)
            view.frame = bounds
        }
        
        return view
    }

}
