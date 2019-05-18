//
//  BookSearchResult.swift
//  Leer
//
//  Created by Raven Weitzel on 5/16/19.
//  Copyright © 2019 Raven Weitzel. All rights reserved.
//

import RealmSwift
import Realm

///directly maps to GET http://openlibrary.org/search.json? response
struct BookResponse: Decodable {
    var start: Int
    var resultCount: Int
    var books: [Book]
    var numFound: Int

    private enum CodingKeys: String, CodingKey {
        case start
        case resultCount = "num_found"
        case numFound
        case books = "docs"
    }
}
