//
//  BaseViewModel.swift
//  Leer
//
//  Created by Raven Weitzel on 5/17/19.
//  Copyright © 2019 Raven Weitzel. All rights reserved.
//

import RealmSwift

///defines a basic view model class with a monitorable item
class BaseViewModel {
    var items: Results<Book> {
        return allBooks.filter("saved == true")
    }

    var allBooks = ModelManager.shared.realm.objects(Book.self)
}
