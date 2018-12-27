//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import Foundation

protocol FavoritesPresenterProtocol {
    
    func displayFavorites()

    var itemsCount: Int { get }
    func itemPresenter(for itemView: PropertyItemViewProtocol, at index: Int) throws -> PropertyItemPresenterProtocol

}

final class FavoritesPresenter: FavoritesPresenterProtocol {

    private weak var view: FavoritesViewProtocol?
    private let favoritesGateway: FavoritesGatewayProtocol
    private let configurator: FavoritesConfiguratorProtocol

    private var favorites: [Property] = []
    
    init(view: FavoritesViewProtocol,
         favoritesGateway: FavoritesGatewayProtocol,
         configurator: FavoritesConfiguratorProtocol) {
        self.view = view
        self.favoritesGateway = favoritesGateway
        self.configurator = configurator
        
        self.favoritesGateway.addDelegate(self)
    }
    
    func displayFavorites() {
        updateFavorites()
        view?.updateView()
    }
    
    var itemsCount: Int { return favorites.count }
    
    func itemPresenter(for itemView: PropertyItemViewProtocol, at index: Int) throws -> PropertyItemPresenterProtocol {
        let property = try favorites.item(at: index)
        return configurator.presenter(for: property, in: itemView)
    }

}

extension FavoritesPresenter {
    
    private func itemIndex(with propertyID: PropertyID) -> Int? {
        return favorites.firstIndex { $0.id == propertyID }
    }

    private func updateFavorites() {
        favorites = favoritesGateway.favorites
    }

}

extension FavoritesPresenter: FavoritesGatewayDelegate {
    
    func favoriteItemAdded(with id: PropertyID) {
        updateFavorites()
        
        if let itemIndex = self.itemIndex(with: id) {
            view?.insertItem(at: itemIndex)
        } else {
            view?.updateView()
        }
    }
    
    func favoriteItemRemoved(with id: PropertyID) {
        let itemIndex = self.itemIndex(with: id)
        updateFavorites()
        
        if let itemIndex = itemIndex {
            view?.removeItem(at: itemIndex)
        } else {
            view?.updateView()
        }
    }
    
}
