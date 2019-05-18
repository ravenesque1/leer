//
//  SecondViewController.swift
//  Leer
//
//  Created by Raven Weitzel on 5/15/19.
//  Copyright © 2019 Raven Weitzel. All rights reserved.
//

import UIKit
import RxSwift
import RxRealmDataSources

class SearchViewController: UIViewController {

    private let search: UISearchController = {
        let sch = UISearchController(searchResultsController: nil)
        sch.hidesNavigationBarDuringPresentation = false

        return sch
    }()

    private lazy var searchViewModel = SearchViewModel()
    let disposeBag: DisposeBag = DisposeBag()

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero)
        tv.translatesAutoresizingMaskIntoConstraints = false

        let identifier = SearchCell.reuseIdentifier
        tv.rowHeight = 100
        tv.register(SearchCell.self, forCellReuseIdentifier: identifier)
        tv.backgroundColor = .groupTableViewBackground
        tv.separatorStyle = .none
        tv.isHidden = true

        return tv
    }()

    private var loadingView: UIActivityIndicatorView = {
        let lv = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        lv.translatesAutoresizingMaskIntoConstraints = false

        return lv
    }()

    private var statusLabel: UILabel = {
        let sl = UILabel(frame: .zero)
        sl.translatesAutoresizingMaskIntoConstraints = false
        sl.numberOfLines = 0
        sl.isHidden = true
        sl.textAlignment = .center

        return sl
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
        bindViewModel()
        updateDisplay()
    }
}


//MARK: - Updating
extension SearchViewController {

    func bindViewModel() {
        searchViewModel.stateSubject
            .bind { self.stateDidChange($0) }
            .disposed(by: disposeBag)
    }
}


//MARK: - Layout
extension SearchViewController {
    private func setupLayout() {

        view.backgroundColor = .groupTableViewBackground

        setupSearchBar()
        setupTableView()
        setupActivityIndicator()
        setupStatusLabel()
        setupNavigation()
    }

    private func setupSearchBar() {
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Lord of the Rings"
        navigationItem.searchController = search
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }

    private func setupTableView() {

        tableView.dataSource = self
        tableView.delegate = self

        view.addSubview(tableView)

        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
    }

    private func setupActivityIndicator() {

        view.addSubview(loadingView)

        loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        loadingView.isHidden = true
    }

    private func setupStatusLabel() {
        view.addSubview(statusLabel)

        statusLabel.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40).isActive = true
        statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        statusLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }

    private func setupNavigation() {
        let infoButton = UIButton(type: .infoLight)
        infoButton.addTarget(self, action: #selector(showInformation), for: .touchUpInside)
        let infoBarButtonItem = UIBarButtonItem(customView: infoButton)
        navigationItem.rightBarButtonItem = infoBarButtonItem
    }
}


//MARK: - Actions
extension SearchViewController {

    @objc private func showInformation() {
        let message = "Swipe to add or remove items from your wishlist."
        showTip(message)
    }
}

//MARK: - Searching
extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {

        guard let text = searchController.searchBar.text, text.count > 2, text != searchViewModel.keyword else {
                updateDisplay()
                return
        }

        NSObject.cancelPreviousPerformRequests(withTarget: self)
        self.perform(#selector(search(_:)), with: text, afterDelay: 1)

    }

    @objc private func search(_ text: String) {
        searchViewModel.search(text)
    }
}

//MARK: - TableViewDataSource
extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchViewModel.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = SearchCell.reuseIdentifier
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)

        if let cell = cell as? SearchCell {
            let book = searchViewModel.items[indexPath.row]
            cell.update(with: book)
        }
        return cell
    }
}


//MARK: - TableViewDelegate
extension SearchViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)
        let book = searchViewModel.items[indexPath.row]

        let details = DetailViewController.instance(with: book)
        navigationController?.pushViewController(details, animated: true)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let count = searchViewModel.items.count
        if (indexPath.row == count - 1) && (count%100 == 0) {
            searchViewModel.nextPage()
        }
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        let savedYet = searchViewModel.items[indexPath.row].saved
        let actionTitle = !savedYet ? "Save to" : "Remove from"

        let saveAction = UITableViewRowAction(style: .normal, title: "\(actionTitle) Wishlist") {_, indexPath in
            self.searchViewModel.toggleSaved(at: indexPath)
            tableView.reloadRows(at: [indexPath], with: .automatic)

            let book = self.searchViewModel.items[indexPath.row]
            let title: String? = book.saved ? "⭐️ Congratulations!" : nil
            let message = book.saved ? "Saved \"\(book.suggestedTitle)\" to" : "Removed \"\(book.suggestedTitle)\" from"

            let toggleAlert = UIAlertController(title: title, message: "\(message) your wishlist.", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            toggleAlert.addAction(ok)

            self.present(toggleAlert, animated: true, completion: nil)
        }


        saveAction.backgroundColor = savedYet ? .red : .savedGold

        return [saveAction]
    }
}


//MARK: - Updating
extension SearchViewController: StateObservable {
    func stateDidChange(_ newState: State) {

        switch newState {
        case .loading:
            setLoading(true)
            statusLabel.isHidden = true
            navigationItem.prompt = nil
        case .error:
            statusLabel.text = searchViewModel.errorPhrase
            statusLabel.isHidden = false
            setLoading(false)
            navigationItem.prompt = nil
        default:
            statusLabel.isHidden = true
            refreshDisplay(forceReload: true)
            setLoading(false)
        }
    }

    private func setLoading(_ isLoading: Bool) {
        loadingView.isHidden = !isLoading

        if isLoading {
            loadingView.startAnimating()
            view.isUserInteractionEnabled = false
        } else {
            loadingView.stopAnimating()
            view.isUserInteractionEnabled = true
        }
    }

    private func updateDisplay() {
        if let text = search.searchBar.text, text.count < 3 {
            tableView.isHidden = true
            statusLabel.isHidden = false
            statusLabel.text = "Start typing to search the OpenLibrary catalog."
        }
    }

    private func refreshDisplay(forceReload: Bool = false) {

        guard let text = search.searchBar.text, text.count > 2 else { return }

        if forceReload {
            tableView.reloadData()
        }

        let hasResults = searchViewModel.items.count > 0

        if hasResults {
            let count = searchViewModel.totalResults
            let descriptor =  count == 1 ? "result" : "results"
            navigationItem.prompt = "\(count) \(descriptor)"

            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }

        tableView.isHidden = !hasResults
        statusLabel.isHidden = hasResults
        statusLabel.text = hasResults ? "" : searchViewModel.noResultsPhrase
    }
}

