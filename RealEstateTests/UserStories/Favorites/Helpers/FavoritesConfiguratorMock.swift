//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import Foundation
@testable import RealEstate

final class FavoritesConfiguratorMock: FavoritesConfiguratorProtocol {
    
    typealias ConfigureViewControllerImpl = (FavoritesCollectionViewController) -> Void
    typealias PresenterForPropertyImpl = (Property, PropertyItemViewProtocol) -> PropertyItemPresenterProtocol
    
    private let configureViewControllerImpl: ConfigureViewControllerImpl
    private let presenterForPropertyImpl: PresenterForPropertyImpl
    
    init(configure configureViewControllerImpl: @escaping ConfigureViewControllerImpl,
         presenter presenterForPropertyImpl: @escaping PresenterForPropertyImpl) {
        self.configureViewControllerImpl = configureViewControllerImpl
        self.presenterForPropertyImpl = presenterForPropertyImpl
    }
    
    func configure(viewController: FavoritesCollectionViewController) {
        configureViewControllerImpl(viewController)
    }
    
    func presenter(for property: Property, in itemView: PropertyItemViewProtocol) -> PropertyItemPresenterProtocol {
        return presenterForPropertyImpl(property, itemView)
    }
    
}
