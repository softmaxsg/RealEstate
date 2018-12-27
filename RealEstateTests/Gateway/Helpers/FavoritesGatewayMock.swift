//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import Foundation
@testable import RealEstate

final class FavoritesGatewayMock: FavoritesGatewayProtocol {
    
    typealias GetFavoritesImpl = () -> [Property]
    typealias AddPropertyImpl = (Property) -> Void
    typealias RemovePropertyImpl = (PropertyID) -> Void
    typealias DelegateManagementImpl = (FavoritesGatewayDelegate) -> Void

    private let getFavoritesImpl: GetFavoritesImpl
    private let addPropertyImpl: AddPropertyImpl
    private let removePropertyImpl: RemovePropertyImpl
    private let addDelegateImpl: DelegateManagementImpl
    private let removeDelegateImpl: DelegateManagementImpl

    init(getFavorites getFavoritesImpl: @escaping GetFavoritesImpl,
         addProperty addPropertyImpl: @escaping AddPropertyImpl,
         removeProperty removePropertyImpl: @escaping RemovePropertyImpl,
         addDelegate addDelegateImpl: @escaping DelegateManagementImpl,
         removeDelegate removeDelegateImpl: @escaping DelegateManagementImpl) {
        self.getFavoritesImpl = getFavoritesImpl
        self.addPropertyImpl = addPropertyImpl
        self.removePropertyImpl = removePropertyImpl
        self.addDelegateImpl = addDelegateImpl
        self.removeDelegateImpl = removeDelegateImpl
    }

    var favorites: [Property] { return getFavoritesImpl() }
    
    func addProperty(_ property: Property) {
        addPropertyImpl(property)
    }
    
    func removeProperty(with propertyID: PropertyID) {
        removePropertyImpl(propertyID)
    }
    
    func addDelegate(_ delegate: FavoritesGatewayDelegate) {
        addDelegateImpl(delegate)
    }
    
    func removeDelegate(_ delegate: FavoritesGatewayDelegate) {
        removeDelegateImpl(delegate)
    }

}
