//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import Foundation

protocol FavoritesGatewayDelegate: class {
    
    func favoriteItemAdded(with id: PropertyID)
    func favoriteItemRemoved(with id: PropertyID)

}

protocol FavoritesGatewayProtocol {

    var favorites: [Property] { get }

    func addProperty(_ property: Property)
    func removeProperty(with propertyID: PropertyID)
    
    func addDelegate(_ delegate: FavoritesGatewayDelegate)
    func removeDelegate(_ delegate: FavoritesGatewayDelegate)

}

final class FavoritesGateway: FavoritesGatewayProtocol {

    private struct DelegateWrapper {
        
        weak var delegate: FavoritesGatewayDelegate?
        
    }
    
    private let dataStorage: FavoritesDataStorageProtocol
    private var delegates: [DelegateWrapper] = []
    
    private(set) lazy var favorites: [Property] = dataStorage.loadAll()
    
    init(dataStorage: FavoritesDataStorageProtocol) {
        self.dataStorage = dataStorage
    }
    
    func addProperty(_ property: Property) {
        guard !favorites.contains(where: { $0.id == property.id }) else { assertionFailure(); return }
        favorites.append(property)
        dataStorage.saveAll(favorites)
        delegates.forEach { $0.delegate?.favoriteItemAdded(with: property.id) }
    }
    
    func removeProperty(with propertyID: PropertyID) {
        guard let index = favorites.firstIndex(where: { $0.id == propertyID }) else { assertionFailure(); return }
        favorites.remove(at: index)
        dataStorage.saveAll(favorites)
        delegates.forEach { $0.delegate?.favoriteItemRemoved(with: propertyID) }
    }

    func addDelegate(_ delegate: FavoritesGatewayDelegate) {
        guard delegates.first(where: searchPredicate(for: delegate)) == nil else { assertionFailure(); return }
        delegates.append(DelegateWrapper(delegate: delegate))
    }
    
    func removeDelegate(_ delegate: FavoritesGatewayDelegate) {
        guard let index = delegates.firstIndex(where: searchPredicate(for: delegate)) else {
            // It's OK when one is not found in case called from deinit. In that case weak property is already `nil`
            return
        }
        delegates.remove(at: index)
    }

}

extension FavoritesGateway {
    
    private func searchPredicate(for delegate: FavoritesGatewayDelegate) -> (DelegateWrapper) -> Bool {
        return { wrapper in
            guard let wrappedDelegate = wrapper.delegate else { return false }
            return delegate === wrappedDelegate
        }
    }
    
}
