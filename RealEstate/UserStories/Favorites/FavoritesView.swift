//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import UIKit

protocol FavoritesViewProtocol: class {
    
    func updateView()
    func insertItem(at index: Int)
    func removeItem(at index: Int)
    
}

final class FavoritesCollectionViewController: UICollectionViewController, CollectionViewCellAdjuster {

    @IBOutlet weak var emptyBackgroundView: UIView?

    private enum ReuseIdentifier: String {
        
        case propertyItem = "PropertyItem"
        
    }
    
    var configurator = FavoritesConfigurator()
    var presenter: FavoritesPresenterProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()

        registerCells()

        adjustCellSize(for: view.bounds.size, safeArea: collectionView.safeAreaInsets)
        configurator.configure(viewController: self)
        
        guard let presenter = self.presenter else { assertionFailure(); return }
        presenter.displayFavorites()
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        let stateView = (presenter?.itemsCount ?? 0) <= 0 ? emptyBackgroundView : nil
        collectionView.backgroundView = stateView
        return stateView == nil ? 1 : 0
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let presenter = self.presenter else { assertionFailure(); return 0 }
        return presenter.itemsCount
    }
    
    override public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:ReuseIdentifier.propertyItem.rawValue, for: indexPath)

        guard let presenter = presenter, let itemCell = cell as? PropertyItemCellView else { assertionFailure(); return cell }
        try? presenter.configure(item: itemCell, at: indexPath.item)
        itemCell.favoriteButtonCallback = { [weak self] in self?.favoriteButtonDidTap(id: $0) }

        return itemCell
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        adjustCellSizeInTransition(to: size, with: coordinator)
    }

}

extension FavoritesCollectionViewController: FavoritesViewProtocol {

    func updateView() {
        collectionView.reloadData()
    }
    
    func insertItem(at index: Int) {
        guard let presenter = self.presenter else { assertionFailure(); return }
        if presenter.itemsCount > 1 {
            collectionView.insertItems(at: [IndexPath(item: index, section: 0)])
        } else {
            collectionView.insertSections(IndexSet(integer: 0))
        }
    }
    
    func removeItem(at index: Int) {
        guard let presenter = self.presenter else { assertionFailure(); return }
        if presenter.itemsCount > 0 {
            collectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
        } else {
            collectionView.deleteSections(IndexSet(integer: 0))
        }
    }

}

extension FavoritesCollectionViewController {
    
    private func registerCells() {
        PropertyItemCellView.register(in: collectionView, with: ReuseIdentifier.propertyItem.rawValue)
    }
    
    private func favoriteButtonDidTap(id: Int) {
        do {
            guard let presenter = self.presenter else { assertionFailure(); return }
            try presenter.unfavorite(with: id)
        } catch {
            collectionView.reloadData()
        }
    }
    
}
