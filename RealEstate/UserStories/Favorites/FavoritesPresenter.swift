//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import Foundation

protocol FavoritesPresenterProtocol {
    
    func displayFavorites()

    var itemsCount: Int { get }
    func configure<ViewType>(item itemView: ViewType, at index: Int) throws where ViewType: PropertyItemViewProtocol

}

final class FavoritesPresenter: FavoritesPresenterProtocol {

    private weak var view: FavoritesViewProtocol?
    private let favoritesGateway: FavoritesGatewayProtocol
    private let priceFormatter: NumberFormatter

    private var items: [PropertyItem] = []
    
    init(view: FavoritesViewProtocol,
         favoritesGateway: FavoritesGatewayProtocol,
         priceFormatter: NumberFormatter) {
        self.view = view
        self.favoritesGateway = favoritesGateway
        self.priceFormatter = priceFormatter
        
        self.favoritesGateway.addDelegate(self)
    }
    
    func displayFavorites() {
        updateFavorites()
    }
    
    var itemsCount: Int { return items.count }
    
    func configure<ViewType>(item itemView: ViewType, at index: Int) throws where ViewType: PropertyItemViewProtocol {
        let item = try items.item(at: index)
        itemView.display(item: item)
    }
    
}

extension FavoritesPresenter {
    
    private func updateFavorites() {
        items = favoritesGateway.favorites.map { PropertyItem(property: $0, favorite: true, priceFormatter: priceFormatter) }
        view?.updateView()
    }

}

extension FavoritesPresenter: FavoritesGatewayDelegate {
    
    func favoriteItemAdded(with id: Int) {
        updateFavorites()
    }
    
    func favoriteItemRemoved(with id: Int) {
        updateFavorites()
    }
    
}
