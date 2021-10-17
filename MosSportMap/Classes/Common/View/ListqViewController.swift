////
////  ListViewController.swift
////  MosSportMap
////
////  Created by Sergeyd on 16.10.2021.
////
//
//import UIKit
//
//class ListqViewController: UITableViewController, UISearchResultsUpdating {
//    var isSearchActive = false
//    var type: ListType!
//    var details: [Detail] = []
//    var filterDetails: [Detail] = []
//    lazy var searchController: UISearchController = {
//        let _searchController = UISearchController(searchResultsController: nil)
//        _searchController.searchBar.autocapitalizationType = .none
//        _searchController.searchBar.placeholder = "Поиск по разделам"
//        _searchController.isActive = true
//        _searchController.delegate = self as? UISearchControllerDelegate
//        return _searchController
//    }()
//
//    //MARK: lifecycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.navigationItem.title = "Меню"
//        self.tableView = UITableView(frame: .zero, style: .insetGrouped)
//        self.tableView.register(UINib(nibName: DetailCell.identifier, bundle: nil), forCellReuseIdentifier: DetailCell.identifier)
//        self.tableView.register(UINib(nibName: SportObjectCell.identifier, bundle: nil), forCellReuseIdentifier: SportObjectCell.identifier)
//        self.configureType()
//        self.configureSearchController()
//        self.isModalInPresentation = true
//    }
//
//    //MARK: Private func
//    func configureSearchController() {
//        self.searchController.searchResultsUpdater = self
//        self.searchController.obscuresBackgroundDuringPresentation = false
//        self.navigationItem.searchController = searchController
//        self.definesPresentationContext = true
//    }
//
//    private func configureType() {
//        switch self.type {
//        case .details(let detail, let report):
//            switch detail.type {
//            case .population:
//                for (ind, population) in populationResponse.populations.enumerated() {
//                    self.details.append(Detail(type: detail.type, title: population.area, place: "\(String(ind + 1)) Место", subtitle: population.population.formattedWithSeparator))
//                }
//            case .square:
//                let sortBySqare = populationResponse.populations.sorted(by: { $0.square > $1.square })
//                for (ind, population) in sortBySqare.enumerated() {
//                    self.details.append(Detail(type: detail.type, title: population.area, place: "\(String(ind + 1)) Место", subtitle: population.square.formattedWithSeparator))
//                }
//            case .departaments:
//                let sortBySqare = report.departments.sorted(by: { $0.title > $1.title })
//                for departament in sortBySqare {
//                    self.details.append(Detail(type: detail.type, title: departament.title, place: "ID: \(departament.id)", subtitle: "Dd"))
//                }
//            case .sportTypes:
//                let sortBySport = report.sportTypes.sorted(by: { $0.title > $1.title })
//                for type in sortBySport {
//                    self.details.append(Detail(type: detail.type, title: type.title, place: "ID: \(type.id)", subtitle: "Dd"))
//                }
//            case .sportObjects:
//                //let sortBySport = report.objects.sorted(by: { $0.title > $1.title })
//                for object in report.objects {
//                    self.details.append(Detail(type: detail.type, title: object.title, place: "ID: \(object.address)", subtitle: object.department.title))
//                }
//            default: break
//            }
//        default: break
//        }
//    }
//
//    //MARK: TableView
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        switch self.type! {
//        case .sport:
//            return 1
//        case .details:
//            if (self.isSearchActive) {
//                return self.filterDetails.count
//            }
//            return self.details.count
//        }
//    }
//
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        switch self.type! {
//        case .details(_, let report):
//            let detail = self.detail(at: indexPath)
//            if (detail.type == .sportObjects) {
//                let controller = ListViewController()
//                let object = report.objects[indexPath.row]
//                controller.type = .sport(object: object)
//                self.push(controller)
//            }
//        default: break
//        }
//    }
//
//    private func detail(at indexPath: IndexPath) -> Detail {
//        if (self.isSearchActive) {
//            return self.filterDetails[indexPath.row]
//        }
//        return self.details[indexPath.row]
//    }
//
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        switch self.type! {
//        case .sport(let object):
//            let detailCell = tableView.dequeueReusableCell(withIdentifier: SportObjectCell.identifier) as! SportObjectCell
//            detailCell.configure(with: object)
//            return detailCell
//        case .details:
//            let detailCell = tableView.dequeueReusableCell(withIdentifier: DetailCell.identifier) as! DetailCell
//            let detail = self.detail(at: indexPath)
//            detailCell.configure(with: detail)
//            return detailCell
//        }
//    }
//}
//
////enum DetailListType {
////    case sportObjects(objects: [SportObject])
////}
////
////class FullInfoListViewController: ListViewController {
////
////    var detailType: DetailListType!
////
////    override func viewDidLoad() {
////        self.navigationItem.title = "Меню"
////        self.tableView = UITableView(frame: .zero, style: .insetGrouped)
////        self.tableView.register(UINib(nibName: SportObjectCell.identifier, bundle: nil), forCellReuseIdentifier: SportObjectCell.identifier)
////        self.configureSearchController()
////       // self.isModalInPresentation = true
////    }
////
////    //MARK: TableView
////    override func numberOfSections(in tableView: UITableView) -> Int {
////        return 1
////    }
////
////    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
////        if (self.isSearchActive) {
////            return self.filterDetails.count
////        }
////        return self.details.count
////    }
////
////    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
////
////    }
////
////    private func detail(at indexPath: IndexPath) -> Detail {
////        if (self.isSearchActive) {
////            return self.filterDetails[indexPath.row]
////        }
////        return self.details[indexPath.row]
////    }
////
////    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
////        let detailCell = tableView.dequeueReusableCell(withIdentifier: SportObjectCell.identifier) as! SportObjectCell
////        let detail = self.detail(at: indexPath)
////        detailCell.configure(with: detail)
////        return detailCell
////    }
////}
