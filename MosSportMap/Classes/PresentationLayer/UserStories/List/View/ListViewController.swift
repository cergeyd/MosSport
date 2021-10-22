//
//  ListListViewController.swift
//  MosSportMap
//
//  Created by sergiusX on 17/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import UIKit
import CoreLocation

/// Тип списка, отображаемого на экране
enum ListType {
    case details(detail: Detail, report: SquareReport)
    case sport(object: SportObject)
    case department(department: Department, sportObjects: [SportObject])
    case filterDepartments
    case filterAreas
    case filterObjects(items: [SportObject])
    case filterSportTypes
    case sports(items: [SportObject.Sport])
    case sportObjectsAround(around: SportObjectsAround)
}

protocol ListViewDelegate: AnyObject {
    func didSelect(population: Population)
    func didSelect(department: Department)
    func didTapShowDepartment(sport object: SportObject)
    func didTapShow(type: SportType, objects: [SportObject])
    func didSelect(filter sport: SportObject)
}

extension ListViewDelegate {
    func didSelect(population: Population) { }
    func didSelect(department: Department) { }
    func didTapShowDepartment(sport object: SportObject) { }
    func didSelect(sport object: SportObject) { }
    func didTapShow(type: SportType, objects: [SportObject]) { }
    func didSelect(filter sport: SportObject) { }
}

class ListViewController: TableViewController {

    struct Config {
        static let sectionHeight = 60.0
        static let searchBarHeight: CGFloat = 50.0
    }

    var output: ListViewOutput!
    var type: ListType!
    var isPage = false
    /// Сегмент
    var index: Int = 0
    weak var delegate: ListViewDelegate?
    private var details: [Detail] = []
    private var filterDetails: [Detail] = []
    private lazy var isNeedSearchView: Bool = {
        switch self.type! {
        case .sport, .sportObjectsAround: return false
        default: return true
        }
    }()

    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.output.didLoadView()
        self.configureTableView()
    }

    //MARK: Private func
    private func configureTableView() {
        self.tableView = UITableView(frame: .zero, style: .insetGrouped)
        self.tableView.register(UINib(nibName: DetailCell.identifier, bundle: nil), forCellReuseIdentifier: DetailCell.identifier)
        self.tableView.register(UINib(nibName: SportObjectCell.identifier, bundle: nil), forCellReuseIdentifier: SportObjectCell.identifier)
    }

    func setupSearchController() {
        switch self.type! {
        case .sport:
            break
        default:
            self.navigationItem.searchController = self.searchController
        }
    }

    @objc override func didTapExport() {
        self.exportRightNavigationBar(isLoading: true)
        Dispatch.after(2.0, completion: { self.exportRightNavigationBar(isLoading: false) })
        let name = self.title ?? "PDF Документ"
        self.pdfData(with: self.tableView, name: name, sourceView: self.navigationItem.rightBarButtonItem!)
        self.murmur(text: "Сохранено", isError: false, subtitle: name)
    }

    private func configureType() {
        switch self.type {
        case .details(let detail, let report):
            switch detail.type {
            case .population:
                for (ind, population) in gPopulationResponse.populations.enumerated() {
                    self.details.append(Detail(type: detail.type, title: population.area, place: "\(String(ind + 1)) Место", subtitle: population.population.formattedWithSeparator))
                }
            case .sportSquare, .square, .sportTypeForOne:
                self.details.append(detail)
            case .squareForOne:
                self.details.append(Detail(type: detail.type, title: "Площадь на одного человека:", place: "Место", subtitle: report.squareForOne.formattedWithSeparator))
            case .objectForOne:
                self.details.append(Detail(type: detail.type, title: report.population.area, place: "Место", subtitle: report.objectForOne.formattedWithSeparator))
            case .department: /// Департаменты в регионе
                for department in report.departments {
                    self.details.append(Detail(type: .department, title: department.title, place: "Идентификатор: \(department.id)", subtitle: "Название"))
                }
            case .sportZones: /// Виды Зоны в регионе
                for sport in report.sports {
                    self.details.append(Detail(type: .region, title: sport.sportType.title, place: "Идентификатор: \(sport.sportAreaID)", subtitle: sport.sportArea))
                }
            case .sportTypes: /// Виды спорта в регионе
                var uniqSportType: Set<SportType> = []
                for type in report.sportTypes {
                    uniqSportType.insert(type)
                }
                let sortBySport = uniqSportType.sorted(by: { $0.id < $1.id })
                for type in sortBySport {
                    self.details.append(Detail(type: .region, title: type.title, place: "ID: \(type.id)", subtitle: "Dd"))
                }
                if (self.index == 1) {
                    let exist = self.details
                    self.details.removeAll()
                    for type in gSportTypes.types {
                        if (!exist.contains(where: { detail in
                            return detail.title == type.title
                        })) {
                            self.details.append(Detail(type: detail.type, title: type.title, place: "ID: \(type.id)", subtitle: "Dd"))
                        }
                    }
                }
            case .sportObjects:
                for object in report.objects {
                    self.details.append(Detail(type: detail.type, title: object.title, place: "ID: \(object.address)", subtitle: object.department.title))
                }
            default: break
            }
        case .filterObjects(let objects): /// Фильтрация по видам спорта
            self.title = "Объекты"
            for object in objects {
                self.details.append(Detail(type: .filter, title: object.title, place: object.address, subtitle: object.department.title))
            }
        case .filterSportTypes: /// Фильтрация по объектам
            self.title = "Видам спорта"
            for type in gSportTypes.types {
                self.details.append(Detail(type: .filter, title: type.title, place: "Идентификатор: \(type.id)", subtitle: "Вид спорта"))
            }
        case .filterDepartments: /// Фильтрация по Департаментам
            self.title = "Департаменты"
            for department in gDepartmentResponse.departments {
                self.details.append(Detail(type: .filter, title: department.title, place: "Идентификатор: \(department.id)", subtitle: "Название"))
            }
        case .filterAreas: /// Фильтрация по районам
            self.title = "Районы, кварталы"
            for population in gPopulationResponse.populations {
                let populationValue = Int(population.population)
                let square = population.square / gSquareToKilometers
                self.details.append(Detail(type: .filter, title: population.area, place: populationValue.peoples() + "/км²", subtitle: "Площадь района: \(square.formattedWithSeparator + " км²")"))
            }
        case .department(let department, let objects): /// Объекты департамента
            self.title = "Объекты департамента"
            self.exportRightNavigationBar(isLoading: false)
            /// Сам департамент
            self.details.append(Detail(type: .departmentHeader, title: department.title, place: "Идентификатор: \(department.id)", subtitle: "\(objects.count) Объекта"))
            /// Объекты
            for sport in objects {
                self.details.append(Detail(type: .sportObjects, title: sport.title, place: "Адрес: \(sport.address)", subtitle: sport.department.title))
            }
        case .sports(let items): /// Типы спорта на объекте
            self.title = "Виды спорта"
            self.exportRightNavigationBar(isLoading: false)
            for item in items {
                let square = item.square?.formattedWithSeparator ?? "Не указана"
                self.details.append(Detail(type: .filter, title: item.sportType.title, place: "Площадь: \(square)", subtitle: item.sportArea))
            }
        default: break
        }
    }

    //MARK: TableView
    override func numberOfSections(in tableView: UITableView) -> Int {
        switch self.type! {
        case .department:
            return self.isNeedSearchView ? (self.isPage ? 3 : 2) : 2
        case .sportObjectsAround(let around):
            return self.objectsInArea(around: around).count + (self.isNeedSearchView ? ((self.isPage ? 1 : 0)) : 0)
        default:
            return self.isNeedSearchView ? (self.isPage ? 2 : 1) : 1
        }
    }
    
    private func objectsInArea(around: SportObjectsAround) -> [SportObject] {
        switch self.index {
        case 0: return around.sportObjectsWalking
        case 1: return around.sportObjectsDistrict
        case 2: return around.sportObjectsArea
        default: return around.sportObjectsCity
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0 && self.isPage && self.isNeedSearchView) { return 0 }
        switch self.type! {
        case .sport:
            return 1
        case .department:
            return section == 0 ? 1 : (self.isSearchActive ? self.filterDetails.count : self.details.count - 1)
        case .sportObjectsAround:
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
            /// Не выновис за скобки т.к. разное поведение
            let detail = self.detail(at: indexPath)
            if (detail.type == .sportObjects) {
                let object = report.objects[indexPath.row]
                self.output.showListDetailScreen(with: .sport(object: object))
            }
            if (detail.type == .department) {
                let department = report.departments[indexPath.row]
                let objects = SharedManager.shared.objects(for: department)
                self.output.showListDetailScreen(with: .department(department: department, sportObjects: objects))
            }
        case .filterAreas:
            self.navigationBar(isLoading: true)
            Dispatch.after(2.5) { self.navigationBar(isLoading: false) }
            Dispatch.global {
                let detail = self.detail(at: indexPath)
                if let population = SharedManager.shared.population(by: detail.title) {
                    Dispatch.main {
                        self.delegate?.didSelect(population: population)
                    }
                }
            }
        case .filterDepartments:
            let detail = self.detail(at: indexPath)
            var department: Department?
            for d in gDepartmentResponse.departments { if (d.title == detail.title) { department = d } }
            if let department = department {
                self.delegate?.didSelect(department: department)
            }
        case .filterObjects(let items):
            let object = items[indexPath.row]
            self.delegate?.didSelect(filter: object)
        case .filterSportTypes:
            self.navigationBar(isLoading: true)
            Dispatch.after(2.5) { self.navigationBar(isLoading: false) }
            Dispatch.global {
                let detail = self.detail(at: indexPath)
                let result = SharedManager.shared.findSportObjects(by: detail.title)
                Dispatch.main {
                    self.delegate?.didTapShow(type: result.type, objects: result.objects)
                }
            }
        case .department(_, let objects):
            if (indexPath.section != 0) {
                let object = objects[indexPath.row]
                self.output.showListDetailScreen(with: .sport(object: object))
            }
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
            return self.details[indexPath.row + 1]
        default:
            if (self.isSearchActive) {
                return self.filterDetails[indexPath.row]
            }
            return self.details[indexPath.row]
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return (self.isPage && self.isNeedSearchView) ? Config.searchBarHeight : 35.0
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        /// Если пагинция - поиск как секция
        if (!self.isNeedSearchView) { return nil }
        if (self.isPage) {
            if (section == 0) {
                return self.searchHeaderView
            } else {
                let hearedTableView = HeaderGrayTableView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 40.0))
                hearedTableView.label.text = self.tableView(titleForHeaderInSection: section)?.uppercased() ?? ""
                return hearedTableView
            }
        }
        return nil
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.tableView(titleForHeaderInSection: section)?.uppercased()
    }

    private func tableView(titleForHeaderInSection section: Int) -> String? {
        switch self.type! {
        case .department: return section == 0 ? "Ведомство" : "Спортивные объекты"
        case .sports: return "Спортивные объекты"
        case .details(let detail, _):
            switch detail.type {
            case .department: return "Департаменты"
            case.sportTypes: return "Виды спорта"
            case .sportObjects: return "Спортивные объекты"
            case .sportZones: return "Спортивные зоны"
            default: return nil
            }
        case .sport, .sportObjectsAround: return "Спортивный объект"
        default: return nil
        }
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
            let object = self.objectsInArea(around: around)[indexPath.section]
            detailCell.configure(with: object, isObjectsAroundHidden: true)
            return detailCell
        default:
            let detailCell = tableView.dequeueReusableCell(withIdentifier: DetailCell.identifier) as! DetailCell
            let detail = self.detail(at: indexPath)
            detailCell.configure(with: detail, indexPath: indexPath)
            return detailCell
        }
    }

    //MARK: Search
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let searchText = searchText.lowercased()
        self.isSearchActive = !searchText.isEmpty
        if (!self.isSearchActive) { self.view.endEditing(true) }
        self.filterDetails = self.details.filter({ (detail) -> Bool in
            let byTitle = detail.title.lowercased().contains(searchText)
            let byPlace = detail.place.lowercased().contains(searchText)
            let bySubTitle = detail.subtitle.lowercased().contains(searchText)
            return byTitle || bySubTitle || byPlace
        })
        self.tableView.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    override func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text?.lowercased() {
            self.isSearchActive = !text.isEmpty
            self.filterDetails = self.details.filter({ (detail) -> Bool in
                let byTitle = detail.title.lowercased().contains(text)
                let byPlace = detail.place.lowercased().contains(text)
                let bySubTitle = detail.subtitle.lowercased().contains(text)
                return byTitle || bySubTitle || byPlace
            })
        }
        self.tableView.reloadData()
    }
}

extension ListViewController: ListViewInput {

    func setupInitialState() {
        self.navigationItem.title = "Меню"
        self.configureType()
        self.setupSearchController()
        self.hideKeyboardWhenTappedAround()
    }
}

extension ListViewController: SportObjectDelegate {
    /// Покажем объект на карте
    func didTapShowOnMap(sport object: SportObject) {
        self.delegate?.didSelect(sport: object)
    }

    func didTapObjectsAround(sport object: SportObject) {
        let around = SharedManager.shared.findSportObjectsAround(object: object)
        self.output.showListDetailScreen(with: .sportObjectsAround(around: around))
    }

    func didTapShowSports(sport object: SportObject) {
        self.output.showListDetailScreen(with: .sports(items: object.sport))
    }

    func didTapShowDepartment(sport object: SportObject) {
        var sports: [SportObject] = []
        for sport in gSportObjectResponse.objects { if (sport.department == object.department) { sports.append(sport) } }
        self.output.showListDetailScreen(with: .department(department: object.department, sportObjects: sports))
    }
}
