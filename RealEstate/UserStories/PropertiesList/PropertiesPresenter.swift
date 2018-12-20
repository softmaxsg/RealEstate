//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import Foundation

protocol PropertiesPresenterProtocol {

    var propertiesCount: Int { get }
    
    func displayProperties()
    func configure(item: PropertyItemViewProtocol, at index: Int)

}
