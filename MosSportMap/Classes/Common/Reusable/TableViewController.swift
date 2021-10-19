//
//  TableViewController.swift
//  MosSportMap
//
//  Created by Sergeyd on 19.10.2021.
//

import UIKit

class TableViewController: UITableViewController, UISearchResultsUpdating {

    var isSearchActive = false
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

    //MARK: Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let children = (self.navigationController?.children.count ?? 1)
        self.isModalInPresentation = children > 1
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
}
