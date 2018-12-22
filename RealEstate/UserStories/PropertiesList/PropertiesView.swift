//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import UIKit

protocol PropertiesViewProtocol: class {

    func updateView()
    func displayLoadingError(_ message: String)
    
}

final class PropertiesCollectionViewController: UICollectionViewController {

    @IBOutlet weak var loadingBackgroundView: UIView?
    @IBOutlet weak var emptyBackgroundView: UIView?
    @IBOutlet weak var errorBackgroundView: ErrorView?

    private enum ReuseIdentifiers: String {
        case propertyItem = "PropertyItem"
    }
    
    private enum State {
        case loading
        case data
        case error(message: String)
    }
    
    var configurator = PropertiesConfigurator()
    var presenter: PropertiesPresenterProtocol?
    var imageLoader: ImageLoader?
    
    private var currentState = State.loading
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureCellSizes(for: view.bounds.size, safeArea: collectionView.safeAreaInsets)
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
        return presenter.propertiesCount
    }
    
    override public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:ReuseIdentifiers.propertyItem.rawValue, for: indexPath)

        guard let presenter = self.presenter, let itemView = cell as? PropertyItemCellView else { assertionFailure(); return cell }
        itemView.imageLoader = imageLoader
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
        currentState = .data
        collectionView.reloadData()
    }
    
    func displayLoadingError(_ message: String) {
        currentState = .error(message: message)
        collectionView.reloadData()
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
    
    private func configureStateView() -> UIView? {
        let result: UIView?
        
        switch currentState {
        case .loading:
            result = loadingBackgroundView
        case .data:
            result = (presenter?.propertiesCount ?? 0) <= 0 ? emptyBackgroundView : nil
        case .error(let message):
            errorBackgroundView?.display(details: message)
            result = errorBackgroundView
        }
        
        return result
    }
    
}
