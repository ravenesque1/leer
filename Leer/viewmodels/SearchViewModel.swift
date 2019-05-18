//
//  SearchViewModel.swift
//  Leer
//
//  Created by Raven Weitzel on 5/16/19.
//  Copyright © 2019 Raven Weitzel. All rights reserved.
//

import RxSwift
import RealmSwift

protocol StateObservable {
    var disposeBag: DisposeBag { get }
    func stateDidChange(_ newState: State)
}

class SearchViewModel: BaseViewModel {

    override var items: Results<Book> {
        return allBooks.filter("lastFoundWith == '\(searchTerm)'")
    }

    ///view monitors this for changes
    var stateSubject = BehaviorSubject<State>(value: .none)

    ///composite query being performed
    var searchTerm = ""

    ///user input
    var keyword = ""

    ///search by author, title, or anything
    private var searchType: SearchType = .any

    ///paged results start at 1, not 0
    private var page: Int = 1

    ///entire result count, not just paged response count
    var totalResults: Int = 0

    private var state: State = .none {
        didSet {
            stateSubject.onNext(state)
        }
    }

    var noResultsPhrase: String {
        var descriptor: String

        switch searchType {
        case .any:
            descriptor = "results for"
        case .author:
            descriptor = "authors matching"
        case .title:
            descriptor = "titles matching"
        }

        return "No \(descriptor) \"\(keyword)\""
    }

    var errorPhrase: String {
        return "Sorry, there was an error searching for \"\(keyword)\""
    }
}

//MARK: - Actions
extension SearchViewModel {
    func search(_ keyword: String,
                type: SearchType = .any,
                page: Int = 1) {

        let formatted = keyword.split(separator: " ").joined(separator: "+")
        state = .loading

        self.keyword = keyword
        self.searchType = type
        self.page = page

        let key = "\(type.rawValue)=\(formatted)"
        searchTerm = key

        OpenLibaryService.shared.search(formatted, type: type, page: page) { result, error in

            guard let result = result, error == nil else {
                self.state = .error
                return
            }

            self.totalResults = result.numFound
            let books = result.books
            let saved = self.allBooks.filter("saved == true").compactMap { $0.key }

            books.forEach { newBook in
                newBook.lastFoundWith = self.searchTerm
                newBook.saved = saved.contains(newBook.key)
            }


            let realm = ModelManager.shared.realm

            try? realm.write {
                realm.add(books, update: true)
            }

            self.state = .none
        }
    }

    func nextPage() {
        search(keyword, type: searchType, page: page + 1)
    }

    func toggleSaved(at indexPath: IndexPath) {

        let book = items[indexPath.row]
        let realm = ModelManager.shared.realm

        try? realm.write {
            book.saved = !book.saved
            realm.add(book, update: true)
        }
    }
}
