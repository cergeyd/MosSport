//
//  TableViewController.swift
//  MosSportMap
//
//  Created by Sergeyd on 19.10.2021.
//

import BusyNavigationBar

class TableViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {

    var isSearchActive = false
    var options = BusyNavigationBarOptions()
    lazy var searchController: UISearchController = {
        let _searchController = UISearchController(searchResultsController: nil)
        _searchController.searchBar.autocapitalizationType = .none
        _searchController.searchBar.placeholder = "Поиск по разделам"
        _searchController.isActive = true
        _searchController.searchResultsUpdater = self
        _searchController.obscuresBackgroundDuringPresentation = false
        _searchController.delegate = self as? UISearchControllerDelegate
        return _searchController
    }()
    lazy var searchHeaderView: SearchHeaderView = {
        let searchHeader = SearchHeaderView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: ListViewController.Config.searchBarHeight))
        searchHeader.searchBar.keyboardAppearance = .dark
        searchHeader.searchBar.delegate = self
        return searchHeader }()

    //MARK: Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureModalStyle()
    }

    //MARK: Private func
    /// Если это не парент - сворачивать нельзя
    private func configureModalStyle() {
        let children = (self.navigationController?.children.count ?? 1)
        self.isModalInPresentation = children > 1
    }
    
    func rightNavigationBar(isLoading: Bool = false) {
        if (isLoading) {
            self.navigationActivity()
        } else {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(didTapExport))
        }
    }

    //MARK: Func
    func exportRightNavigationBar(isLoading: Bool = false) {
        if (isLoading) {
            self.navigationActivity()
        } else {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(didTapExport))
        }
    }

    @objc func didTapExport() {

    }

    func updateSearchResults(for searchController: UISearchController) {

    }

    func navigationBar(isLoading: Bool) {
        if (isLoading) {
            self.navigationController?.navigationBar.start(self.options)
        } else {
            self.navigationController?.navigationBar.stop()
        }
    }
}
