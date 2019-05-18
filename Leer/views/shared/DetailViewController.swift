//
//  DetailViewController.swift
//  Leer
//
//  Created by Raven Weitzel on 5/17/19.
//  Copyright © 2019 Raven Weitzel. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    private lazy var detailViewModel = DetailViewModel()
    private var book: Book!

    private var coverImageView: UIImageView = {
        let civ = UIImageView(frame: .zero)
        civ.translatesAutoresizingMaskIntoConstraints = false
        civ.image = UIImage(named: "bookPlaceholder")

        return civ
    }()

    private var savedImageView: UIImageView = {
        let siv = UIImageView(frame: .zero)
        siv.translatesAutoresizingMaskIntoConstraints = false
        siv.image = UIImage(named: "empty")
        siv.tintColor = .savedGold
        
        return siv
    }()

    private var scrollView: UIScrollView = {
        let sv = UIScrollView(frame: .zero)
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private var contentView: UIView = {
        let cv = UIView(frame: .zero)
        cv.translatesAutoresizingMaskIntoConstraints = false

        return cv
    }()

    private var informationLabel: UILabel = {
        let il = UILabel(frame: .zero)
        il.translatesAutoresizingMaskIntoConstraints = false
        il.numberOfLines = 0

        return il
    }()

    private var toggleSaveButton: UIButton = {
        let tsb = UIButton(frame: .zero)
        tsb.translatesAutoresizingMaskIntoConstraints = false
        tsb.layer.cornerRadius = 10

        return tsb
    }()

    static func instance(with book: Book) -> DetailViewController {
        let dvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController

        dvc.book = book

        return dvc
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
        update()
    }
}


//MARK: - Updating
extension DetailViewController {

    private func update() {

        let placeholder = UIImage(named: "bookPlaceholder")
        coverImageView.image = placeholder
        coverImageView.contentMode = .center
        coverImageView.backgroundColor = .groupTableViewBackground

        if let imageUrlString = book.imageUrl(for: .large),
            let imageUrl = URL(string: imageUrlString) {
            coverImageView.af_setImage(withURL: imageUrl, placeholderImage: UIImage(named: "bookPlaceholder"))
        }

        var information = [
            "Title": book.suggestedTitle,
            "Author": book.authorName,
            "ISBN": book.isbn,
        ]

        if let publishYear = book.publishYear.value {
            information["Published"] = "\(publishYear)"
        }

        var info = ""

        for key in information.keys.sorted() {
            if let val = information[key] {
                info += "\(key):\t \(val)\n\n"
            }
        }

        if let firstSentence = book.teaser {
            info += "\nExcerpt:\n\n\"\(firstSentence)\""
        }

        informationLabel.text = info

        let toggleTitle = !book.saved ? "Save to Wishlist" : "Remove from Wishlist"
        let toggleColor = !book.saved ? UIColor.savedGold : .red

        toggleSaveButton.setTitle(toggleTitle, for: .normal)
        toggleSaveButton.setTitleColor(toggleColor, for: .normal)
        toggleSaveButton.layer.borderColor = toggleColor.cgColor
        toggleSaveButton.layer.borderWidth = 2.0

        savedImageView.setSaved(book.saved)
    }
}

//MARK: - Action
extension DetailViewController {

    ///user would like to save or unsave the book
    @objc private func toggleAction() {
        detailViewModel.toggle(book)
        update()
    }
}


//MARK: - Layout
extension DetailViewController {
    private func setupLayout() {
        title = book.suggestedTitle
        setupScrollView()
    }

    private func setupScrollView() {
        view.addSubview(scrollView)

        scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true

        setupContentView()
    }

    private func setupContentView() {

        scrollView.addSubview(contentView)

        contentView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        contentView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true

        setupImageView()
        setupInformationLabel()
        setupToggleSaveButton()
    }

    private func setupImageView() {
        contentView.addSubview(coverImageView)

        coverImageView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor).isActive = true
        coverImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        coverImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        coverImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5).isActive = true

        setupSavedImageView()
    }

    private func setupInformationLabel() {
        contentView.addSubview(informationLabel)

        informationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        informationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        informationLabel.topAnchor.constraint(equalTo: coverImageView.bottomAnchor, constant: 30).isActive = true
    }

    private func setupToggleSaveButton() {
        contentView.addSubview(toggleSaveButton)

        toggleSaveButton.topAnchor.constraint(equalTo: informationLabel.bottomAnchor, constant: 20).isActive = true
        toggleSaveButton.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor).isActive = true
        toggleSaveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        toggleSaveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        toggleSaveButton.heightAnchor.constraint(equalToConstant: 60.0).isActive = true

        toggleSaveButton.addTarget(self, action: #selector(toggleAction), for: .touchUpInside)
    }

    private func setupSavedImageView() {
        coverImageView.addSubview(savedImageView)

        savedImageView.trailingAnchor.constraint(equalTo: coverImageView.trailingAnchor, constant: -10).isActive = true
        savedImageView.bottomAnchor.constraint(equalTo: coverImageView.bottomAnchor, constant: -10).isActive = true
        savedImageView.widthAnchor.constraint(equalTo: savedImageView.heightAnchor).isActive = true
        savedImageView.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
    }
}
