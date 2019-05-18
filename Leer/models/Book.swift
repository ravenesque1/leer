//
//  Book.swift
//  Leer
//
//  Created by Raven Weitzel on 5/15/19.
//  Copyright © 2019 Raven Weitzel. All rights reserved.
//

import RealmSwift
import Realm

enum ImageSize: String {
    case small = "S"
    case medium = "M"
    case large = "L"
}

@objcMembers public class Book: Object, Decodable {

    dynamic var suggestedTitle: String = ""

    let coverId = RealmOptional<Int>()
    dynamic var authorName: String = ""
    dynamic var key: String = ""
    dynamic var lastFoundWith: String = ""
    dynamic var saved: Bool = false
    dynamic var isbn: String = ""
    dynamic var teaser: String?
    let publishYear = RealmOptional<Int>()

    private enum CodingKeys: String, CodingKey {
        case titleSuggest = "title_suggest"
        case editionKey = "edition_key"
        case coverId = "cover_i"
        case isbn
        case hasFullText = "has_fulltext"
        case text
        case authorName = "author_name"
        case contributor
        case seed
        case oclc
        case ia
        case authorKey = "author_key"
        case subject
        case title
        case lendingIdentifier = "lending_identifier_s"
        case collections = "ia_collection_s"
        case firstPublishYear = "first_publish_year"
        case type
        case ebookCount = "ebook_count_i"
        case publishPlace = "publish_place"
        case boxId = "ia_box_id"
        case editionCount = "edition_count"
        case oclcId = "id_oclc"
        case key
        case goodreadsId = "id_goodreads"
        case publicScan = "public_scan_b"
        case overdriveId = "id_overdrive"
        case publisher
        case language
        case lccn
        case lastModified = "last_modified_i"
        case lendingEdition = "lending_edition_s"
        case libraryThingId = "id_librarything"
        case coverEditionKey = "cover_edition_key"
        case firstSentence = "first_sentence"
        case authorNameAlternative = "author_alternative_name"
        case publishYear = "publish_year"
        case printDisabled = "print_disabled_s"
        case place
        case time
        case publishDate = "publish_date"
    }

    override public class func primaryKey() -> String {
        return "key"
    }

    required public init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: CodingKeys.self)
        suggestedTitle = try container.decode(String.self, forKey: .titleSuggest)
        coverId.value = try? container.decode(Int.self, forKey: .coverId)
        if let authors = try? container.decode([String].self, forKey: .authorName), let name = authors.first {
            authorName = name
        }

        key = try container.decode(String.self, forKey: .key)

        if let isbns = try? container.decode([String].self, forKey: .isbn), let isbnNum = isbns.first {
            isbn = isbnNum
        }

        if let sentences = try? container.decode([String].self, forKey: .firstSentence) {
            teaser = sentences.first
        }

        if let publishYears = try? container.decode([Int].self, forKey: .publishYear) {
            publishYear.value = publishYears.first
        }

        super.init()
    }

    required init() {
        super.init()
    }

    // MARK: - Realm

    required init(realm: RLMRealm, schema: RLMObjectSchema) {
        super.init(realm: realm, schema: schema)
    }

    required init(value: Any, schema: RLMSchema) {
        super.init(value: value, schema: schema)
    }
}

extension Book {

    ///build URL string for desired image size
    func imageUrl(for size: ImageSize = .small) -> String? {
        guard let cover = coverId.value else { return nil }

        return "http://covers.openlibrary.org/b/id/\(cover)-\(size.rawValue).jpg"
    }
}
