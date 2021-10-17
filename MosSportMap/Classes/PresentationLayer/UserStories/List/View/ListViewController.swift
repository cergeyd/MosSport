//
//  ListListViewController.swift
//  MosSportMap
//
//  Created by sergiusX on 17/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import UIKit

enum ListType {
    case details(detail: Detail, report: SquareReport)
    case sport(object: SportObject)
    case filterDepartments
}

class ListViewController: UITableViewController {

    var output: ListViewOutput!
    var type: ListType!
    var isExist = false
    let keyboardHandler = KeyboardHandler.shared
    lazy var searchHeaderView: SearchHeaderView = {
        let searchHeader = SearchHeaderView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: 40.0))
        searchHeader.searchBar.keyboardAppearance = .dark
        searchHeader.searchBar.delegate = self
        //self.tableView.scrollIndicatorInsets = UIEdgeInsets(top: 40.0, left: 0, bottom: 0, right: 0)
        return searchHeader }()
    private var isSearchActive: Bool { let text = self.searchHeaderView.searchBar.text ?? ""; return !text.isEmpty }
    private var details: [Detail] = []
    private var filterDetails: [Detail] = []
    private lazy var searchController: UISearchController = {
        let _searchController = UISearchController(searchResultsController: nil)
        _searchController.searchBar.autocapitalizationType = .none
        _searchController.searchBar.placeholder = "Поиск по разделам"
        _searchController.isActive = true
        _searchController.delegate = self as? UISearchControllerDelegate
        return _searchController
    }()

    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.output.didLoadView()
        self.configureTableView()
        self.configureType()
        self.setupSearchController()
        self.hideKeyboardWhenTappedAround()
       // self.keyboardHandler.add(delegate: self)
    }

    //MARK: Private func
    private func configureTableView() {
        self.tableView = UITableView(frame: .zero, style: .insetGrouped)
        self.tableView.register(UINib(nibName: DetailCell.identifier, bundle: nil), forCellReuseIdentifier: DetailCell.identifier)
        self.tableView.register(UINib(nibName: SportObjectCell.identifier, bundle: nil), forCellReuseIdentifier: SportObjectCell.identifier)
    }

    func setupSearchController() {
//        self.searchController.searchResultsUpdater = self
//        self.searchController.obscuresBackgroundDuringPresentation = false
//        self.navigationItem.searchController = self.searchController
//        self.definesPresentationContext = true
    }

    private func configureType() {
        switch self.type {
        case .details(let detail, let report):
            switch detail.type {
            case .population:
                for (ind, population) in populationResponse.populations.enumerated() {
                    self.details.append(Detail(type: detail.type, title: population.area, place: "\(String(ind + 1)) Место", subtitle: population.population.formattedWithSeparator))
                }
            case .sportSquare:
                self.details.append(detail)
            case .square:
                self.details.append(detail)
            case .sportTypeForOne:
                self.details.append(detail)
            case .squareForOne:
                self.details.append(Detail(type: detail.type, title: "report.population.area", place: "Место", subtitle: report.squareForOne.formattedWithSeparator))
            case .objectForOne:
                self.details.append(Detail(type: detail.type, title: report.population.area, place: "Место", subtitle: report.objectForOne.formattedWithSeparator))
            case .department:
                let sortBySqare = report.departments.sorted(by: { $0.id < $1.id })
                for department in sortBySqare {
                    self.details.append(Detail(type: detail.type, title: department.title, place: "ID: \(department.id)", subtitle: "Dd"))
                }
            case .sportTypes:
                let sortBySport = report.sportTypes.sorted(by: { $0.id < $1.id })
                for type in sortBySport {
                    self.details.append(Detail(type: detail.type, title: type.title, place: "ID: \(type.id)", subtitle: "Dd"))
                }
                if (!self.isExist) {
                    let exist = self.details
                    self.details.removeAll()
                    for type in sportTypes.types {
                        if (!exist.contains(where: { detail in
                            return detail.title == type.title
                        })) {
                            self.details.append(Detail(type: detail.type, title: type.title, place: "ID: \(type.id)", subtitle: "Dd"))
                        }
                    }
                }
            case .sportObjects:
                //let sortBySport = report.objects.sorted(by: { $0.id > $1.id }) sportSquare
                for object in report.objects {
                    self.details.append(Detail(type: detail.type, title: object.title, place: "ID: \(object.address)", subtitle: object.department.title))
                }
            default: break
            }
        case .filterDepartments:
            for department in departmentResponse.departments {
                self.details.append(Detail(type: .filter, title: department.title, place: "ID: \(department.id)", subtitle: "Dd"))
            }
        default: break
        }
    }

    //MARK: TableView
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) { return 0 }
        switch self.type! {
        case .sport:
            return 1
        default:
            if (self.isSearchActive) {
                return self.filterDetails.count
            }
            return self.details.count
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch self.type! {
        case .details(_, let report):
            let detail = self.detail(at: indexPath)
            if (detail.type == .sportObjects) {
                let object = report.objects[indexPath.row]
                self.output.showListDetailScreen(with: .sport(object: object))
            }
        default: break
        }
    }

    private func detail(at indexPath: IndexPath) -> Detail {
        if (self.isSearchActive) {
            return self.filterDetails[indexPath.row]
        }
        return self.details[indexPath.row]
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if (section == 0) {
            return self.searchHeaderView
        }
        return nil
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch self.type! {
        case .sport(let object):
            let detailCell = tableView.dequeueReusableCell(withIdentifier: SportObjectCell.identifier) as! SportObjectCell
            detailCell.configure(with: object)
            return detailCell
        default:
            let detailCell = tableView.dequeueReusableCell(withIdentifier: DetailCell.identifier) as! DetailCell
            let detail = self.detail(at: indexPath)
            detailCell.configure(with: detail)
            return detailCell
        }
    }
}

extension ListViewController: ListViewInput {

    func setupInitialState() {
        self.navigationItem.title = "Меню"
        self.isModalInPresentation = true
    }
}

extension ListViewController: UISearchBarDelegate {

//    func updateSearchResults(for searchController: UISearchController) {
//        if let text = searchController.searchBar.text?.lowercased() {
//            self.isSearchActive = !text.isEmpty
//            self.filterDetails = self.details.filter({ (detail) -> Bool in
//                let byTitle = detail.title.lowercased().contains(text)
//                let bySubTitle = detail.subtitle.lowercased().contains(text)
//                return byTitle || bySubTitle
//            })
//        }
//        self.tableView.reloadData()
//    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let text = searchText.lowercased()
        self.filterDetails = self.details.filter({ (detail) -> Bool in
            let byTitle = detail.title.lowercased().contains(text)
            let bySubTitle = detail.subtitle.lowercased().contains(text)
            return byTitle || bySubTitle
        })
        self.tableView.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

//extension ListViewController: KeyboardHandlerDelegate, KeyboardHandlerDataSource {
//
//    func currentScrollView() -> UIScrollView? { return self.tableView }
//
////    func didUpdateKeyboard(height: CGFloat, duration: Double, isShown: Bool) {
////        self.logoButton.alpha = isShown ? 0.0 : 1.0
////        self.renewPasswordButton.alpha = isShown ? 0.0 : 1.0
////        self.bottomConstraint.constant = isShown ? height + 12.0 : 24.0
////        self.headerConstraint.constant = isShown ? -116.0 : 0.0
////        UIView.animate(withDuration: duration) {
////            self.view.layoutIfNeeded()
////        }
////    }
//}
