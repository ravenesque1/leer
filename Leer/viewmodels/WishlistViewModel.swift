//
//  WishlistViewModel.swift
//  Leer
//
//  Created by Raven Weitzel on 5/17/19.
//  Copyright © 2019 Raven Weitzel. All rights reserved.
//

import RealmSwift

class WishlistViewModel: BaseViewModel {

    ///allows user to unsave after a long-press
    func unsave(at indexPath: IndexPath) {

        let book = items[indexPath.row]
        let realm = ModelManager.shared.realm

        try? realm.write {
            book.saved = false
            realm.add(book, update: true)
        }
    }
}
