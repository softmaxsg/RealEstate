//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import Foundation

enum FavoritesPresenterError: Error {
    
    case invalidID
    
}

protocol FavoritesPresenterProtocol {
    
    func displayFavorites()

    var itemsCount: Int { get }
    func configure<ViewType>(item itemView: ViewType, at index: Int) throws where ViewType: PropertyItemViewProtocol
    
    func unfavorite(with id: Int) throws

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
        view?.updateView()
    }
    
    var itemsCount: Int { return items.count }
    
    func configure<ViewType>(item itemView: ViewType, at index: Int) throws where ViewType: PropertyItemViewProtocol {
        let item = try items.item(at: index)
        itemView.display(item: item)
    }
    
    func unfavorite(with id: Int) throws {
        guard let _ = items.first(where: { $0.id == id }) else { throw FavoritesPresenterError.invalidID }
        favoritesGateway.removeProperty(with: id)
    }

}

extension FavoritesPresenter {
    
    private func itemIndex(with propertyID: Int) -> Int? {
        return items.firstIndex { $0.id == propertyID }
    }

    private func updateFavorites() {
        items = favoritesGateway.favorites.map { PropertyItem(property: $0, favorite: true, priceFormatter: priceFormatter) }
    }

}

extension FavoritesPresenter: FavoritesGatewayDelegate {
    
    func favoriteItemAdded(with id: Int) {
        updateFavorites()
        
        if let itemIndex = self.itemIndex(with: id) {
            view?.insertItem(at: itemIndex)
        } else {
            view?.updateView()
        }
    }
    
    func favoriteItemRemoved(with id: Int) {
        let itemIndex = self.itemIndex(with: id)
        updateFavorites()
        
        if let itemIndex = itemIndex {
            view?.removeItem(at: itemIndex)
        } else {
            view?.updateView()
        }
    }
    
}
