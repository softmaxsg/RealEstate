//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import UIKit

protocol PropertiesViewProtocol: class {

    func updateView()
    func displayLoadingError(_ message: String)
    
}

final class PropertiesCollectionViewController: UICollectionViewController {

    var configurator = PropertiesConfigurator()
    var presenter: PropertiesPresenterProtocol?

}

extension PropertiesCollectionViewController: PropertiesViewProtocol {

    func updateView() {
    }
    
    func displayLoadingError(_ message: String) {
    }
    
}
