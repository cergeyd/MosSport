//
//  ListListViewController.swift
//  MosSportMap
//
//  Created by sergiusX on 17/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import UIKit
import CoreLocation

enum ListType {
    case details(detail: Detail, report: SquareReport)
    case sport(object: SportObject)
    case department(department: Department, sportObjects: [SportObject])
    case filterDepartments
    case filterAreas
    case filterObjects
    case sports(items: [SportObject.Sport])
    case sportObjectsAround(around: SportObjectsAround)
}

protocol ListViewDelegate: AnyObject {
    func didSelect(population: Population)
    func didSelect(department: Department)
    func didTapShowDepartment(sport object: SportObject)
    func didSelect(sport object: SportObject)
}

extension ListViewDelegate {
    func didSelect(population: Population) { }
    func didSelect(department: Department) { }
    func didTapShowDepartment(sport object: SportObject) { }
    func didSelect(sport object: SportObject) { }
}

class ListViewController: UITableViewController {

    struct Config {
        static let sectionHeight = 60.0
    }

    var output: ListViewOutput!
    var type: ListType!
    var index: Int = 0
    // var isModal = true
    let keyboardHandler = KeyboardHandler.shared
    weak var delegate: ListViewDelegate?
    lazy var searchHeaderView: SearchHeaderView = {
        let searchHeader = SearchHeaderView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: Config.sectionHeight))
        searchHeader.searchBar.keyboardAppearance = .dark
        searchHeader.searchBar.delegate = self
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
                if (self.index == 1) {
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
        case .filterAreas:
            for population in populationResponse.populations {
                self.details.append(Detail(type: .filter, title: population.area, place: population.population.formattedWithSeparator, subtitle: "Dd"))
            }
        case .department(let department, let objects):
            self.details.append(Detail(type: .department, title: department.title, place: "ID: \(department.id)", subtitle: "Dd"))
            for sport in objects {
                self.details.append(Detail(type: .sportObjects, title: sport.title, place: "ID: \(sport.address)", subtitle: sport.department.title))
            }
        case .sports(let items):
            for item in items {
                let square = item.square?.formattedWithSeparator ?? "Не указана"
                self.details.append(Detail(type: .sportObjects, title: item.sportType.title, place: "Площадь: \(square)", subtitle: item.sportArea))
            }
//        case .sportObjects(let around):

        default: break
        }
    }

    //MARK: TableView
    override func numberOfSections(in tableView: UITableView) -> Int {
        switch self.type! {
        case .sport:
            return 1
        case .department:
            return 2
        default:
            return 2
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.type! {
        case .sport:
            return 1
        case .department:
            return section == 0 ? 1 : (self.isSearchActive ? self.filterDetails.count : self.details.count)
        case .sportObjectsAround(let around):
            return self.objectsInArea(around: around).count
        default:
            if (section == 0) { return 0 }
            if (self.isSearchActive) {
                return self.filterDetails.count
            }
            return self.details.count
        }
    }

    private func objectsInArea(around: SportObjectsAround) -> [SportObject] {
        switch self.index {
        case 0:
            return around.sportObjectsWalking
        case 1:
            return around.sportObjectsDistrict
        case 2:
            return around.sportObjectsArea
        default:
            return around.sportObjectsCity
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch self.type! {
        case .details(_, let report):
            /// Не выновис за скобки т.к. разное поведение
            let detail = self.detail(at: indexPath)
            if (detail.type == .sportObjects) {
                let object = report.objects[indexPath.row]
                self.output.showListDetailScreen(with: .sport(object: object))
            }
        case .filterAreas:
            let detail = self.detail(at: indexPath)
            if let population = SharedManager.shared.population(by: detail.title) {
                self.delegate?.didSelect(population: population)
            }
        case .filterDepartments:
            let detail = self.detail(at: indexPath)
            for department in departmentResponse.departments {
                if (department.title == detail.title) {
                    self.delegate?.didSelect(department: department)
                }
            }
        case .department(_, let objects):
            let object = objects[indexPath.row]
            self.output.showListDetailScreen(with: .sport(object: object))
        default: break
        }
    }

    private func detail(at indexPath: IndexPath) -> Detail {
        switch self.type! {
        case .department:
            if (indexPath.section == 0) {
                return self.details[0]
            } else if (self.isSearchActive) {
                return self.filterDetails[indexPath.row]
            }
            return self.details[indexPath.row]
        default:
            if (self.isSearchActive) {
                return self.filterDetails[indexPath.row]
            }
            return self.details[indexPath.row]
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? Config.sectionHeight : 0.0
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch self.type! {
        case .sport: break
//        case .sportObjectsAround:
//            let hearedTableView = HeaderGrayTableView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: Config.sectionHeight))
//            switch section {
//            case 0:
//                return self.searchHeaderView
//            case 1:
//                hearedTableView.label.text = "Шаговая доступность"
//            case 2:
//                hearedTableView.label.text = "Районное"
//            case 3:
//                hearedTableView.label.text = "Окружное"
//            default:
//                hearedTableView.label.text = "Городское"
//            }
//            return hearedTableView
        default:
            if (section == 0) {
                return self.searchHeaderView
            }
        }
        return nil
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch self.type! {
        case .sport(let object):
            let detailCell = tableView.dequeueReusableCell(withIdentifier: SportObjectCell.identifier) as! SportObjectCell
            detailCell.delegate = self
            detailCell.configure(with: object, isObjectsAroundHidden: false)
            return detailCell
        case .sportObjectsAround(let around):
            let detailCell = tableView.dequeueReusableCell(withIdentifier: SportObjectCell.identifier) as! SportObjectCell
            detailCell.delegate = self
            let object = self.objectsInArea(around: around)[indexPath.row]
            detailCell.configure(with: object, isObjectsAroundHidden: true)
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
        // self.isModalInPresentation = self.isModal
    }
}

struct SportObjectsAround {
    let sportObjectsArea: [SportObject]
    let sportObjectsDistrict: [SportObject]
    let sportObjectsWalking: [SportObject]
    let sportObjectsCity: [SportObject]
}

extension ListViewController: UISearchBarDelegate, SportObjectDelegate {

    func didTapShowOnMap(sport object: SportObject) {
        print(self.delegate)
        self.delegate?.didSelect(sport: object)
    }

    func didTapObjectsAround(sport object: SportObject) {
        var sportObjectsArea: [SportObject] = []
        var sportObjectsDistrict: [SportObject] = []
        var sportObjectsWalking: [SportObject] = []
        var sportObjectsCity: [SportObject] = []

        let currentLocation = CLLocation(latitude: object.coordinate.latitude, longitude: object.coordinate.longitude)
        for object in sportObjectResponse.objects {
            let location = CLLocation(latitude: object.coordinate.latitude, longitude: object.coordinate.longitude)
            let distance = currentLocation.distance(from: location)
            switch distance {
            case 1..<501:
                sportObjectsWalking.append(object)
            case 500..<1001:
                sportObjectsDistrict.append(object)
            case 1000..<3001:
                sportObjectsArea.append(object)
            case 3000..<5001:
                sportObjectsCity.append(object)
            default:
                break
            }
        }
        let around = SportObjectsAround(sportObjectsArea: sportObjectsArea, sportObjectsDistrict: sportObjectsDistrict, sportObjectsWalking: sportObjectsWalking, sportObjectsCity: sportObjectsCity)
        self.output.showListDetailScreen(with: .sportObjectsAround(around: around))
    }

    func didTapShowSports(sport object: SportObject) {
        self.output.showListDetailScreen(with: .sports(items: object.sport))
    }

    func didTapShowDepartment(sport object: SportObject) {
        var sports: [SportObject] = []
        for sport in sportObjectResponse.objects {
            if (sport.department == object.department) {
                sports.append(sport)
            }
        }
        self.output.showListDetailScreen(with: .department(department: object.department, sportObjects: sports))
    }

//    func didTapShowDepartment(sport object: SportObject) {
//       // self.delegate?.didTapShowDepartment(sport: object)
//    }

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

class HeaderGrayTableView: View {

    lazy var label: UILabel = {
        var label = UILabel()
        label.textColor = AppStyle.color(for: .title)
        label.numberOfLines = 1
        label.font = AppStyle.font(size: .title, width: .medium)
        self.addSubview(label)
        return label
    }()

    //MARK: Lifecycle
    override func setUpLayout() {
        super.setUpLayout()
        self.backgroundColor = .clear
        self.label.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(32.0)
            make.bottom.equalToSuperview().inset(6.0)
        }
    }
}

class View: UIView {

    public static var identifier: String {
        return String(describing: self)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUpLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func setUpLayout() {

    }
}
