//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import UIKit

protocol PropertiesListViewProtocol: class {

    func updateView()
    func displayLoadingError(_ message: String)
    
}

final class PropertiesListCollectionViewController: UICollectionViewController, CollectionViewCellAdjuster {

    @IBOutlet weak var loadingBackgroundView: UIView?
    @IBOutlet weak var emptyBackgroundView: UIView?
    @IBOutlet weak var errorBackgroundView: ErrorView?

    private enum ReuseIdentifier: String {
        
        case unknown
        case propertyItem = "PropertyItem"
        case advertisementItem = "AdvertisementItem"
        
        init(itemType: ItemType) {
            switch itemType {
            case .property: self = .propertyItem
            case .advertisement: self = .advertisementItem
            }
        }
            
    }
    
    private enum State {
        case loading
        case data
        case error(message: String)
    }
    
    var configurator = PropertiesListConfigurator()
    var presenter: PropertiesListPresenterProtocol?
    
    private var currentState = State.loading
    
    override func viewDidLoad() {
        super.viewDidLoad()

        registerCells()

        adjustCellSize(for: view.bounds.size, safeArea: collectionView.safeAreaInsets)
        configurator.configure(viewController: self)
        
        guard let presenter = self.presenter else { assertionFailure(); return }
        presenter.displayProperties()
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        let stateView = configureStateView()
        collectionView.backgroundView = stateView
        return stateView == nil ? 1 : 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let presenter = self.presenter else { assertionFailure(); return 0 }
        return presenter.itemsCount
    }
    
    override public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let presenter = presenter, let itemType = try? presenter.itemType(at: indexPath.item) else {
            assertionFailure()
            // Should not happen but there should be a return value in this function
            return collectionView.dequeueReusableCell(withReuseIdentifier: ReuseIdentifier.unknown.rawValue, for: indexPath)
        }

        let reuseIdentifier = ReuseIdentifier(itemType: itemType)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:reuseIdentifier.rawValue, for: indexPath)

        switch itemType {
        case .property:
            configure(cell: cell, of: PropertyItemCellView.self, at: indexPath.item)
        case .advertisement:
            configure(cell: cell, of: AdvertisementItemCellView.self, at: indexPath.item)
        }

        return cell
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        adjustCellSizeInTransition(to: size, with: coordinator)
    }

}

extension PropertiesListCollectionViewController: PropertiesListViewProtocol {

    func updateView() {
        currentState = .data
        collectionView.reloadData()
    }
    
    func displayLoadingError(_ message: String) {
        currentState = .error(message: message)
        collectionView.reloadData()
    }
    
}

extension PropertiesListCollectionViewController {
    
    private func registerCells() {
        PropertyItemCellView.register(in: collectionView, with: ReuseIdentifier.propertyItem.rawValue)
        AdvertisementItemCellView.register(in: collectionView, with: ReuseIdentifier.advertisementItem.rawValue)
    }
    
    private func configureStateView() -> UIView? {
        let result: UIView?
        
        switch currentState {
        case .loading:
            result = loadingBackgroundView
        case .data:
            result = (presenter?.itemsCount ?? 0) <= 0 ? emptyBackgroundView : nil
        case .error(let message):
            errorBackgroundView?.display(details: message)
            result = errorBackgroundView
        }
        
        return result
    }

    private func configure<T>(cell: UICollectionViewCell, of type: T.Type, at index: Int) where T: PropertyItemCellView {
        guard let presenter = presenter, let cell = cell as? T else { assertionFailure(); return }
        guard let itemPresenter = (try? presenter.itemPresenter(for: cell, at: index)) as? PropertyItemPresenterProtocol else { assertionFailure(); return }
        cell.presenter = itemPresenter
        itemPresenter.updateView()
    }

    private func configure<T>(cell: UICollectionViewCell, of type: T.Type, at index: Int) where T: AdvertisementItemCellView {
        guard let presenter = presenter, let cell = cell as? T else { assertionFailure(); return }
        guard let itemPresenter = (try? presenter.itemPresenter(for: cell, at: index)) as? AdvertisementItemPresenterProtocol else { assertionFailure(); return }
        cell.presenter = itemPresenter
        itemPresenter.updateView()
    }

}
