//
//  FirstViewController.swift
//  Leer
//
//  Created by Raven Weitzel on 5/15/19.
//  Copyright © 2019 Raven Weitzel. All rights reserved.
//

import UIKit
import RxSwift
import RxRealmDataSources

class WishlistViewController: UIViewController {

    private lazy var wishlistViewModel = WishlistViewModel()
    let disposeBag: DisposeBag = DisposeBag()


    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(WishlistCell.self, forCellWithReuseIdentifier: WishlistCell.reuseIdentifier)

        cv.backgroundColor = .groupTableViewBackground

        return cv
    }()

    private var searchButton: UIButton = {
        let sl = UIButton(frame: .zero)
        sl.translatesAutoresizingMaskIntoConstraints = false
        sl.isHidden = false
        sl.setTitle("Search for Books", for: .normal)
        sl.setTitleColor(.black, for: .normal)
        sl.layer.cornerRadius = 10
        sl.layer.borderColor = UIColor.black.cgColor
        sl.layer.borderWidth = 2.0

        return sl
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
        bindDataSource()
        bindDelegate()
    }
}

//MARK: - Binding/Updating
extension WishlistViewController {
    private func bindDataSource() {

        let dataSource = RxCollectionViewRealmDataSource<Book>(
        cellIdentifier: WishlistCell.reuseIdentifier, cellType: WishlistCell.self) {cell, _, update in
            cell.update(with: update)
        }

        Observable.changeset(from: wishlistViewModel.items)
            .do( onNext: { _ in

                let count = self.wishlistViewModel.items.count
                self.searchButton.isHidden = count > 0

                let descriptor = count == 1 ? "book" : "books"
                self.navigationItem.prompt = "\(count) \(descriptor)"
            })
            .bind(to: collectionView.rx.realmChanges(dataSource))
            .disposed(by: disposeBag)
    }

    private func bindDelegate() {

        collectionView.rx.itemSelected
            .bind { [weak self] indexPath in

                if let book = self?.wishlistViewModel.items[indexPath.row] {
                    let details = DetailViewController.instance(with: book)
                    DispatchQueue.main.async {
                        self?.navigationController?.pushViewController(details, animated: true)
                    }
                }
            }
            .disposed(by: disposeBag)
    }
}


//MARK: - Layout
extension WishlistViewController {

    private func setupLayout() {
        setupCollectionView()
        setupSearchButton()
        setupNavigation()
    }

    private func setupNavigation() {
        let infoButton = UIButton(type: .infoLight)
        infoButton.addTarget(self, action: #selector(showInformation), for: .touchUpInside)
        let infoBarButtonItem = UIBarButtonItem(customView: infoButton)
        navigationItem.rightBarButtonItem = infoBarButtonItem
    }

    private func setupCollectionView() {

        view.addSubview(collectionView)

        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let width = (CGFloat(view.frame.width) / 3.0)
            layout.itemSize = CGSize(width: width, height: width * 1.4)
        }

        collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        collectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        collectionView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true

        let longTap = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(_:)))
        longTap.minimumPressDuration = 0.3
        longTap.delegate = self
        longTap.delaysTouchesBegan = true

        collectionView.addGestureRecognizer(longTap)
    }

    private func setupSearchButton() {
        view.addSubview(searchButton)

        searchButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40).isActive = true
        searchButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        searchButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        searchButton.heightAnchor.constraint(equalToConstant: 60.0).isActive = true

        searchButton.addTarget(self, action: #selector(didTapSearch), for: .touchUpInside)
    }
}


//MARK: - Actions
extension WishlistViewController {

    ///user would like to remove a particular wishlist item
    @objc private func didLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        guard gestureRecognizer.state == .ended else {
            return
        }

        let point = gestureRecognizer.location(in: collectionView)

        if let indexPath = collectionView.indexPathForItem(at: point) {

            let book = wishlistViewModel.items[indexPath.row]
            let title = "Remove \"\(book.suggestedTitle)\"?"
            let message = "This will remove \"\(book.suggestedTitle)\" by \(book.authorName) from your wishlist."

            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let remove = UIAlertAction(title: "OK", style: .destructive) { _ in
                self.wishlistViewModel.unsave(at: indexPath)
            }

            alert.addAction(cancel)
            alert.addAction(remove)

            present(alert, animated: true, completion: nil)
        }
    }

    ///user would like to switch to search tab
    @objc private func didTapSearch() {
        tabBarController?.selectedIndex = 1
    }

    ///user would like to some help/information
    @objc private func showInformation() {
        let message = "Long-press to remove wishlist items."
        showTip(message)
    }
}

//MARK: - GestureRecognizer
extension WishlistViewController: UIGestureRecognizerDelegate { }
