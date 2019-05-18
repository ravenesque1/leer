//
//  DetailViewModel.swift
//  Leer
//
//  Created by Raven Weitzel on 5/17/19.
//  Copyright © 2019 Raven Weitzel. All rights reserved.
//

import RealmSwift

class DetailViewModel {

    ///save or unsave a book
    func toggle(_ book: Book) {
        let realm = ModelManager.shared.realm

        try? realm.write {
            book.saved = !book.saved
            realm.add(book, update: true)
        }
    }
}

