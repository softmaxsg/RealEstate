//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import UIKit

final class ErrorView: UIView {
    
    @IBOutlet weak var detailsLabel: UILabel?
    
    override func awakeFromNib() {
        detailsLabel?.text = nil
    }
    
    func display(details: String) {
        detailsLabel?.text = details
    }
    
}
