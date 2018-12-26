//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import Foundation
@testable import RealEstate

final class FavoritesDataStorageMock: FavoritesDataStorageProtocol {

    typealias LoadAllImpl = () -> [Property]
    typealias SaveAllImpl = ([Property]) -> Void
    
    private let loadAllImpl: LoadAllImpl
    private let saveAllImpl: SaveAllImpl
    
    init(loadAll loadAllImpl: @escaping LoadAllImpl, saveAll saveAllImpl: @escaping SaveAllImpl) {
        self.loadAllImpl = loadAllImpl
        self.saveAllImpl = saveAllImpl
    }

    func loadAll() -> [Property] {
        return loadAllImpl()
    }
    
    func saveAll(_ properties: [Property]) {
        saveAllImpl(properties)
    }
    
}
