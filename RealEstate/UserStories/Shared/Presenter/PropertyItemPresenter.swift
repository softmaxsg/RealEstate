//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import Foundation

protocol PropertyItemPresenterProtocol: PropertyListItemPresenterProtocol {

    func toggleFavoriteState()

}

final class PropertyItemPresenter: PropertyItemPresenterProtocol {

    private weak var view: PropertyItemViewProtocol?
    private let property: Property
    private let favoritesGateway: FavoritesGatewayProtocol
    private let priceFormatter: NumberFormatter
    
    init(view: PropertyItemViewProtocol, property: Property, favoritesGateway: FavoritesGatewayProtocol, priceFormatter: NumberFormatter) {
        self.view = view
        self.property = property
        self.favoritesGateway = favoritesGateway
        self.priceFormatter = priceFormatter
        
        self.favoritesGateway.addDelegate(self)
    }
    
    func updateView() {
        view?.display(item: PropertyItem(
            property: property,
            favorite: isFavorite,
            priceFormatter: priceFormatter
        ))
    }
    
    func toggleFavoriteState() {
        if isFavorite {
            favoritesGateway.removeProperty(with: property.id)
        } else {
            favoritesGateway.addProperty(property)
        }
    }
    
}

extension PropertyItemPresenter {
    
    private var isFavorite: Bool {
        return favoritesGateway.favorites.contains(property)
    }
    
}

extension PropertyItemPresenter: FavoritesGatewayDelegate {

    func favoriteItemAdded(with id: PropertyID) {
        updateView()
    }
    
    func favoriteItemRemoved(with id: PropertyID) {
        updateView()
    }
    
}
