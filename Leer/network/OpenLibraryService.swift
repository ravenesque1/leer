//
//  OpenLibraryService.swift
//  Leer
//
//  Created by Raven Weitzel on 5/16/19.
//  Copyright © 2019 Raven Weitzel. All rights reserved.
//

import UIKit
import Alamofire

enum State {
    case none
    case loading
    case success
    case error
}

enum SearchType: String {
    case title
    case author
    case any = "q"
}

class OpenLibaryService {

    var sessionManager: SessionManager
    static let shared = OpenLibaryService()

    init() {
        sessionManager = Alamofire.SessionManager.default
    }

    private let coverBaseUrl = "//http://covers.openlibrary.org/b/id/"
    private let searchBaseUrl = "http://openlibrary.org/search.json?"

    func search(_ keyword: String,
                type: SearchType = .any,
                page: Int = 1,
                completion: @escaping (BookResponse?, Error?) -> ()) {

        guard let encodedKeyword = keyword.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            completion(nil, nil)
            return
        }

        let url = "\(searchBaseUrl)\(type.rawValue)=\(encodedKeyword)&page=\(page)"

        print("GET \(url)")

        fetch(url: url) { data, error in
            guard let data = data, error == nil else {
                completion(nil, error)
                return
            }

            do {
                let result = try JSONDecoder().decode(BookResponse.self, from: data)
                completion(result, nil)
            } catch let decodingError {
                completion(nil, decodingError)
            }
        }
    }

    private func fetch(url: String, completion: @escaping (Data?, Error?) -> ()) {

        sessionManager.request(url).responseData { response in
            switch response.result {
            case .success:
                completion(response.result.value, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
}
