//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import Foundation
@testable import RealEstate

final class PropertiesListConfiguratorMock: PropertiesListConfiguratorProtocol {

    typealias ConfigureViewControllerImpl = (PropertiesListCollectionViewController) -> Void
    typealias PresenterForPropertyImpl = (Property, PropertyItemViewProtocol) -> PropertyItemPresenterProtocol
    typealias PresenterForAdvertisementImpl = (URL, AdvertisementItemViewProtocol) -> AdvertisementItemPresenterProtocol

    private let configureViewControllerImpl: ConfigureViewControllerImpl
    private let presenterForPropertyImpl: PresenterForPropertyImpl
    private let presenterForAdvertisementImpl: PresenterForAdvertisementImpl

    init(configure configureViewControllerImpl: @escaping ConfigureViewControllerImpl,
         propertyPresenter presenterForPropertyImpl: @escaping PresenterForPropertyImpl,
         advertisementPresenter presenterForAdvertisementImpl: @escaping PresenterForAdvertisementImpl) {
        self.configureViewControllerImpl = configureViewControllerImpl
        self.presenterForPropertyImpl = presenterForPropertyImpl
        self.presenterForAdvertisementImpl = presenterForAdvertisementImpl
    }

    func configure(viewController: PropertiesListCollectionViewController) {
        configureViewControllerImpl(viewController)
    }
    
    func presenter(for property: Property, in itemView: PropertyItemViewProtocol) -> PropertyItemPresenterProtocol {
        return presenterForPropertyImpl(property, itemView)
    }
    
    func presenter(for advertisementImageURL: URL, in itemView: AdvertisementItemViewProtocol) -> AdvertisementItemPresenterProtocol {
        return presenterForAdvertisementImpl(advertisementImageURL, itemView)
    }

}
