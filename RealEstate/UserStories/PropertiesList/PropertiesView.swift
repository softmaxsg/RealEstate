//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import UIKit

protocol PropertiesViewProtocol: class {

    func updateView()
    func displayLoadingError(_ message: String)
    
}

final class PropertiesCollectionViewController: UICollectionViewController {

    private enum ReuseIdentifiers: String {
        case propertyItem = "PropertyItem"
    }
    
    var configurator = PropertiesConfigurator()
    var presenter: PropertiesPresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureCellSizes(for: view.bounds.size, safeArea: collectionView.safeAreaInsets)
        configurator.configure(viewController: self)
        
        guard let presenter = self.presenter else { assertionFailure(); return }
        presenter.displayProperties()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let presenter = self.presenter else { assertionFailure(); return 0 }
        return presenter.propertiesCount
    }
    
    override public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:ReuseIdentifiers.propertyItem.rawValue, for: indexPath)

        guard let presenter = self.presenter, let itemView = cell as? PropertyItemViewProtocol else { assertionFailure(); return cell }
        presenter.configure(item: itemView, at: indexPath.item)
        
        return cell
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        collectionView.collectionViewLayout.invalidateLayout()
        
        coordinator.animate(
            alongsideTransition: { _ in
                self.configureCellSizes(for: size, safeArea: self.collectionView.safeAreaInsets)
            },
            completion: { _ in
                self.collectionView.collectionViewLayout.invalidateLayout()
            }
        )
    }

}

extension PropertiesCollectionViewController: PropertiesViewProtocol {

    func updateView() {
        collectionView.reloadData()
    }
    
    func displayLoadingError(_ message: String) {
    }
    
}

extension PropertiesCollectionViewController {
    
    private func configureCellSizes(for size: CGSize, safeArea: UIEdgeInsets) {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { assertionFailure(); return }
        
        let viewWidth = size.width - (safeArea.left + safeArea.right)
        let columnsCount = CGFloat(Int(viewWidth) / 500 + 1)
        let spacing: CGFloat = (viewWidth / columnsCount) < 350 ? 10 : 20
        
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        layout.itemSize = CGSize(
            width: (viewWidth - spacing * (columnsCount + 1)) / columnsCount,
            height: 250
        )
    }
    
}
