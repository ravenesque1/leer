//
//  SearchCell.swift
//  Leer
//
//  Created by Raven Weitzel on 5/15/19.
//  Copyright © 2019 Raven Weitzel. All rights reserved.
//

import UIKit
import AlamofireImage

class SearchCell: UITableViewCell {

    static let reuseIdentifier = "SearchCell"

    var cardView: UIView = {
        let cv = UIView()
        cv.backgroundColor = .white
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.layer.cornerRadius = 10
        cv.clipsToBounds = true

        return cv
    }()

    var coverImageView: UIImageView = {
        let civ = UIImageView()
        civ.image = UIImage(named: "bookPlaceholder")
        civ.contentMode = UIViewContentMode.scaleAspectFill
        civ.translatesAutoresizingMaskIntoConstraints = false
        civ.clipsToBounds = true

        return civ
    }()

    private var informationStackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.distribution = .fillProportionally
        sv.axis = .vertical

        return sv
    }()

    var bookTitleLabel: UILabel = {
        let btl = UILabel()
        btl.translatesAutoresizingMaskIntoConstraints = false
        btl.font = UIFont.boldSystemFont(ofSize: 20.0)
        btl.numberOfLines = 0

        return btl
    }()

    var bookAuthorLabel: UILabel = {
        let bal = UILabel()
        bal.translatesAutoresizingMaskIntoConstraints = false
        bal.font = UIFont.italicSystemFont(ofSize: 14.0)
        bal.numberOfLines = 2

        return bal
    }()

    var savedImageView: UIImageView = {
        let siv = UIImageView(frame: .zero)
        siv.contentMode = .scaleAspectFit
        siv.translatesAutoresizingMaskIntoConstraints = false
        siv.tintColor = .savedGold

        return siv
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayout()
    }
}


//MARK: - Updating
extension SearchCell {
    func update(with book: Book) {
        bookTitleLabel.text = book.suggestedTitle
        bookAuthorLabel.text = book.authorName

        savedImageView.setSaved(book.saved)

        let placeholder = UIImage(named: "bookPlaceholder")
        coverImageView.image = placeholder
        coverImageView.contentMode = .center

        if let imageUrlString = book.imageUrl(),
            let imageUrl = URL(string: imageUrlString) {
            coverImageView.af_setImage(withURL: imageUrl, placeholderImage: placeholder) { response in
                self.coverImageView.contentMode = self.coverImageView.image == placeholder ? .center : .scaleAspectFill
            }
        }
    }
}


//MARK: - Layout
extension SearchCell {
    private func setupLayout() {

        contentView.backgroundColor = .clear
        backgroundColor = .clear

        setupCardView()
    }

    private func setupCardView() {
        contentView.addSubview(cardView)

        cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        cardView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10).isActive = true
        cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
        cardView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10).isActive = true

        setupCoverImageView()
        setupInformation()
        setupSavedView()
    }

    private func setupCoverImageView() {

        cardView.addSubview(coverImageView)

        coverImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor).isActive = true
        coverImageView.widthAnchor.constraint(equalTo: coverImageView.heightAnchor, multiplier: 0.75).isActive = true
        coverImageView.topAnchor.constraint(equalTo: cardView.topAnchor).isActive = true
        coverImageView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor).isActive = true
    }

    private func setupInformation() {
        cardView.addSubview(informationStackView)

        informationStackView.leadingAnchor.constraint(equalTo: coverImageView.trailingAnchor, constant: 10).isActive = true
        informationStackView.centerYAnchor.constraint(equalTo: coverImageView.centerYAnchor).isActive = true
        informationStackView.heightAnchor.constraint(equalTo: coverImageView.heightAnchor, multiplier: 0.7).isActive = true
        informationStackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -10).isActive = true

        informationStackView.addArrangedSubview(bookTitleLabel)
        informationStackView.addArrangedSubview(bookAuthorLabel)
    }

    private func setupSavedView() {
        cardView.addSubview(savedImageView)

        savedImageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 10).isActive = true
        savedImageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -10).isActive = true
        savedImageView.widthAnchor.constraint(equalTo: savedImageView.heightAnchor).isActive = true
        savedImageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
    }
}
