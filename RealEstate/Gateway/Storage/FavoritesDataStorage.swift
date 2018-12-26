//
//  Copyright © 2018 Vitaly Chupryk. All rights reserved.
//

import Foundation

protocol FavoritesDataStorageProtocol {

    func loadAll() -> [Property]
    func saveAll(_ properties: [Property])
    
}

final class FavoritesDataStorage: FavoritesDataStorageProtocol {

    private static let storageURL: URL = {
        let fileManager = FileManager.default
        // That's really weird if there is no documents directory and there is no way to recover from this error. So, `!` should be fine here
        let documentDirectory = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        return documentDirectory.appendingPathComponent("favorites.dat")
    }()
    
    private let storageURL: URL
    
    // For testing purposes
    init(url: URL = FavoritesDataStorage.storageURL) {
        self.storageURL = url
    }
    
    func loadAll() -> [Property] {
        guard let data = try? Data(contentsOf: storageURL) else { return [] }
        return (try? PropertyListDecoder().decode([Property].self, from: data)) ?? []
    }
    
    func saveAll(_ properties: [Property]) {
        guard let data = try? PropertyListEncoder().encode(properties) else { return }
        try? data.write(to: storageURL)
    }

}
