//
//  WishlistCell.swift
//  Leer
//
//  Created by Raven Weitzel on 5/17/19.
//  Copyright © 2019 Raven Weitzel. All rights reserved.
//

import UIKit
import AlamofireImage

class WishlistCell: UICollectionViewCell {

    static let reuseIdentifier = "WishlistCell"

    var coverImageView: UIImageView = {
        let civ = UIImageView()
        civ.image = UIImage(named: "bookPlaceholder")
        civ.contentMode = UIViewContentMode.center
        civ.translatesAutoresizingMaskIntoConstraints = false
        civ.clipsToBounds = true

        return civ
    }()

    private var informationStackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.distribution = .fillProportionally
        sv.axis = .vertical
        sv.isHidden = true
        sv.spacing = -5

        return sv
    }()

    var bookTitleLabel: UILabel = {
        let btl = UILabel()
        btl.translatesAutoresizingMaskIntoConstraints = false
        btl.font = UIFont.boldSystemFont(ofSize: 20.0)
        btl.numberOfLines = 0
        btl.minimumScaleFactor = 0.5

        return btl
    }()

    var bookAuthorLabel: UILabel = {
        let bal = UILabel()
        bal.translatesAutoresizingMaskIntoConstraints = false
        bal.font = UIFont.italicSystemFont(ofSize: 14.0)
        bal.numberOfLines = 2
        bal.minimumScaleFactor = 0.5

        return bal
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayout()
    }
}


//MARK: - Layout
extension WishlistCell {

    private func setupLayout() {

        backgroundColor = .white
        contentView.layer.borderColor = UIColor.black.cgColor

        setupCoverImageView()
        setupInformation()
    }

    private func setupCoverImageView() {

        contentView.addSubview(coverImageView)

        coverImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        coverImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor).isActive = true
        coverImageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        coverImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }

    private func setupInformation() {
        contentView.addSubview(informationStackView)

        informationStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        informationStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
        informationStackView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.4).isActive = true
        informationStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true

        informationStackView.addArrangedSubview(bookTitleLabel)
        informationStackView.addArrangedSubview(bookAuthorLabel)
    }
}


//MARK: - Updating
extension WishlistCell {
    func update(with book: Book) {

        let placeholder = UIImage(named: "bookPlaceholder")
        coverImageView.image = placeholder
        coverImageView.contentMode = .center

        informationStackView.isHidden = true
        bookTitleLabel.text = book.suggestedTitle
        bookAuthorLabel.text = book.authorName
        contentView.layer.borderWidth = 0.5

        if let imageUrlString = book.imageUrl(for: .medium),
            let imageUrl = URL(string: imageUrlString) {
            coverImageView.af_setImage(withURL: imageUrl, placeholderImage: UIImage(named: "bookPlaceholder")) { response in
                let imageExists = self.coverImageView.image != placeholder
                self.coverImageView.contentMode = !imageExists ? .center : .scaleAspectFill
                self.informationStackView.isHidden = imageExists
                self.contentView.layer.borderWidth = imageExists ? 0.0 : 0.5
            }
        } else {
            informationStackView.isHidden = false
        }
    }
}

