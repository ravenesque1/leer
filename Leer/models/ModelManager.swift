//
//  ModelManager.swift
//  Leer
//
//  Created by Raven Weitzel on 5/16/19.
//  Copyright © 2019 Raven Weitzel. All rights reserved.
//

import RealmSwift
import KeychainSwift

class ModelManager {
    static let shared = ModelManager()

    lazy var realm: Realm = {
        return (try? Realm())!
    }()

    let encryptionKey = "leer_encryption_key"
}

extension ModelManager {

    ///a private encryption key guaranteed to exist
    private static var encryptionKey: Data {
        let keychain = KeychainSwift()

        guard let key = keychain.getData(ModelManager.shared.encryptionKey) else {
            var key = Data(count: 64)
            let digestBytes = UnsafeMutablePointer<UInt8>.allocate(capacity: 64)
            defer { digestBytes.deallocate() }
            _ = key.withUnsafeMutableBytes { _ in
                SecRandomCopyBytes(kSecRandomDefault, 64, digestBytes)
            }

            keychain.set(key, forKey: ModelManager.shared.encryptionKey)
            return Data(bytes: digestBytes, count: 64)
        }
        return key
    }

    ///ensures no crashes between realm updates
    static var prodConfig: Realm.Configuration {
        var config = Realm.Configuration(
            encryptionKey: encryptionKey,
            deleteRealmIfMigrationNeeded: true
        )

        config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent("leer.realm")
        debugPrint("🔮 Created Realm at: \(config.fileURL!)")
        return config
    }

    class func setProdConfigForDefaultRealm() {
        Realm.Configuration.defaultConfiguration = prodConfig
    }

}
