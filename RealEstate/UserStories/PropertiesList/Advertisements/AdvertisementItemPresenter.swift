//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import Foundation

protocol AdvertisementItemPresenterProtocol: PropertyListItemPresenterProtocol { }

final class AdvertisementItemPresenter: AdvertisementItemPresenterProtocol {
    
    private weak var view: AdvertisementItemViewProtocol?
    private let advertisementImageURL: URL
    
    init(view: AdvertisementItemViewProtocol, advertisementImageURL: URL) {
        self.view = view
        self.advertisementImageURL = advertisementImageURL
    }
    
    func updateView() {
        view?.display(item: AdvertisementItem(image: advertisementImageURL))
    }
    
}
