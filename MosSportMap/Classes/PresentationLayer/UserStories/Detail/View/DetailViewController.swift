//
//  DetailDetailViewController.swift
//  MosSportMap
//
//  Created by sergiusX on 15/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import UIKit

enum DetailType {
    case region
    case square
    case department
    case departmentHeader
    case sportTypes
    case population
    case sportObjects
    case sportZones
    case sportSquare
    case squareForOne
    case objectForOne
    case sportTypeForOne
    case filter
}

protocol DetailViewDelegate: AnyObject {
    func didSelect(sport object: SportObject)
}

class DetailViewController: TableViewController {

    var output: DetailViewOutput!
    var report: SquareReport?
    var section: DepartmentSection?
    var sportTypeSection: SportTypeSection?
    private var sections: [DetailSection] = []
    private var filterDetails: [Detail] = []
    weak var delegate: DetailViewDelegate?
    
    var randomPlace: Int = {
        return Int(arc4random_uniform(12) + 1)
    }()
    var randomPlace1: Int = {
        return Int(arc4random_uniform(12) + 1)
    }()
    var randomPlace2: Int = {
        return Int(arc4random_uniform(12) + 1)
    }()
    var randomPlace3: Int = {
        return Int(arc4random_uniform(12) + 1)
    }()
    var randomPlace4: Int = {
        return Int(arc4random_uniform(12) + 1)
    }()
    var randomPlace5: Int = {
        return Int(arc4random_uniform(12) + 1)
    }()
    var randomPlace6: Int = {
        return Int(arc4random_uniform(12) + 1)
    }()
    var randomPlace7: Int = {
        return Int(arc4random_uniform(12) + 1)
    }()

    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.output.didLoadView()
        /// Отчёт
        if let report = self.report { self.configureSection(with: report) }
        /// Объекты депртамента
        else if let section = self.section { self.configureSection(with: section) }
        /// Виды спорта
        else if let sportTypeSection = self.sportTypeSection { self.configureSection(with: sportTypeSection) }
    }

    //MARK: Private func
    @objc override func didTapExport() {
        self.rightNavigationBar(isLoading: true)
        Dispatch.after(2.0, completion: { self.rightNavigationBar(isLoading: false) })
        self.pdfData(with: self.tableView, name: "Информация о районе \(self.report?.population.area ?? "")", sourceView: self.navigationItem.rightBarButtonItem!)
    }

    private func configureTableView() {
        self.tableView = UITableView(frame: .zero, style: .insetGrouped)
        self.tableView.register(UINib(nibName: DetailRegionCell.identifier, bundle: nil), forCellReuseIdentifier: DetailRegionCell.identifier)
        self.tableView.register(UINib(nibName: DetailCell.identifier, bundle: nil), forCellReuseIdentifier: DetailCell.identifier)
    }

    /// Фильтрация по типам игр
    private func configureSection(with sportTypeSection: SportTypeSection) {
        var details: [Detail] = []
        for sportObject in sportTypeSection.sportObjects {
            let detail = Detail(type: .population, title: sportObject.title, place: sportObject.address, subtitle: sportObject.availabilityType.rawValue)
            details.append(detail)
        }
        let typeSection = DetailSection(title: "Вид спорта", details: [Detail(type: .department, title: sportTypeSection.type.title, place: "Всего объектов: \(sportTypeSection.sportObjects.count)", subtitle: "Вид спорта")])
        let sportSection = DetailSection(title: "Спортивные объекты", details: details)
        self.sections.append(typeSection)
        self.sections.append(sportSection)
        self.navigationItem.searchController = self.searchController
    }

    /// Фильтрация по департаментам
    private func configureSection(with departmentSection: DepartmentSection) {
        var details: [Detail] = []
        for sportObject in departmentSection.sportObjects {
            let detail = Detail(type: .sportObjects, title: sportObject.title, place: sportObject.address, subtitle: sportObject.availabilityType.rawValue)
            details.append(detail)
        }
        let departmentSection = DetailSection(title: "Департамент", details: [Detail(type: .departmentHeader, title: departmentSection.department.title, place: "Идентификатор: \(departmentSection.department.id)", subtitle: "Название департамента")])
        let sportSection = DetailSection(title: "Спортивные объекты", details: details)
        self.sections.append(departmentSection)
        self.sections.append(sportSection)
        self.navigationItem.searchController = self.searchController
    }

    private func configureSection(with report: SquareReport) {
        let region = Detail(type: .region, title: report.population.area, place: "", subtitle: "Данные о районе")
        let area = DetailSection(title: "Район", details: [region])
        self.sections.append(area)

        /// Плотность населения
        let populationValue = Int(report.population.population)
        let population = Detail(type: .population, title: populationValue.peoples() + "/км²", place: "\(self.randomPlace) место по Москве", subtitle: "Плотность населения на квадратный километр:")
        let populationSection = DetailSection(title: "Население", details: [population])

        /// Площадь района
        let square = Detail(type: .square, title: (report.population.square / gSquareToKilometers).formattedWithSeparator + " км²", place: "\(self.randomPlace1) место по Москве", subtitle: "Площадь района:")
        let squareSportObjects = Detail(type: .sportSquare, title: (report.allSquare).formattedWithSeparator + " м²", place: "\(self.randomPlace2) место по Москве", subtitle: "Площадь спортивных объектов:")
        let squareForOne = Detail(type: .squareForOne, title: report.squareForOne.formattedWithSeparator + " м²", place: "\(self.randomPlace3) место по Москве", subtitle: "Площадь спортивных объектов на человека:")
        let objectForOne = Detail(type: .objectForOne, title: report.objectForOne.formattedWithSeparator + " объекта", place: "\(self.randomPlace4) место по Москве", subtitle: "Спортивные объекты для одного человека:")
        let sportTypeForOne = Detail(type: .sportTypeForOne, title: report.sportTypeForOne.formattedWithSeparator + " вида", place: "\(self.randomPlace5) место по Москве", subtitle: "Виды спорта для одного человека:")
        let sqareSection = DetailSection(title: "Данные", details: [square, squareSportObjects, squareForOne, objectForOne, sportTypeForOne])

        /// Департаменты района
        let departments = Detail(type: .department, title: report.departments.count.departments(), place: "\(self.randomPlace6) место по Москве", subtitle: "Департаменты района:")
        let departmentsSection = DetailSection(title: "Департаменты", details: [departments])

        /// Виды спортивных площадок
        let sportTypes = Detail(type: .sportTypes, title: "\(report.sportTypes.count) Вида спортивных услуг", place: "\(self.randomPlace7) место по Москве", subtitle: "Типы спортивных объектов:")
        /// Cпортивные площадки в районе
        let sports = Detail(type: .sportObjects, title: "\(report.objects.count) Объектов", place: "\(self.randomPlace) место по Москве", subtitle: "Cпортивныe объекты в районе:")
        let sportZones = Detail(type: .sportZones, title: "\(report.sports.count) Спортивных зон", place: "\(self.randomPlace) место по Москве", subtitle: "Cпортивныe зоны:")

        let sportsSection = DetailSection(title: "Спортивные объекты", details: [sportTypes, sports, sportZones])

        self.sections.append(populationSection)
        self.sections.append(sqareSection)
        self.sections.append(departmentsSection)
        self.sections.append(sportsSection)
    }

    //MARK: Search
    override func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text?.lowercased() {
            self.isSearchActive = !text.isEmpty
            let details = self.sections.flatMap({ $0.details })
            self.filterDetails = details.filter({ (detail) -> Bool in
                let byTitle = detail.title.lowercased().contains(text)
                let byPlace = detail.place.lowercased().contains(text)
                let bySubTitle = detail.subtitle.lowercased().contains(text)
                return byTitle || bySubTitle || byPlace
            })
        }
        self.tableView.reloadData()
    }
}

extension DetailViewController: DetailViewInput {

    func setupInitialState() {
        self.navigationItem.title = "Детали"
        self.configureTableView()
        self.rightNavigationBar()
        self.isModalInPresentation = true
    }
}

//MARK: TableView
extension DetailViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        if (self.isSearchActive) { return 1 }
        return self.sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.isSearchActive) { return self.filterDetails.count }
        return self.sections[section].details.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section].title
    }

    private func section(at indexPath: IndexPath) -> DetailSection {
        if (self.isSearchActive) { return DetailSection(title: "РЕЗУЛЬТАТЫ ПОИСКА", details: self.filterDetails) }
        return self.sections[indexPath.section]
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = self.section(at: indexPath)
        let detail = section.details[indexPath.row]
        switch detail.type {
        case .region:
            let cell = tableView.dequeueReusableCell(withIdentifier: DetailRegionCell.identifier, for: indexPath) as! DetailRegionCell
            cell.configure(with: self.report!)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: DetailCell.identifier, for: indexPath) as! DetailCell
            cell.configure(with: detail, indexPath: indexPath)
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /// Отчёт
        if let report = self.report {
            if (indexPath.section > 2) {
                let section = self.sections[indexPath.section]
                let detail = section.details[indexPath.row]
                self.output.didTapShow(detail: detail, report: report)
            }
        } else {
            /// Игры департамента
            if let section = self.section {
                if (indexPath.section > 0) {
                    let sportObject = section.sportObjects[indexPath.row]
                    self.output.didTapShow(detail: sportObject)
                    self.delegate?.didSelect(sport: sportObject)
                }
            } else if let sportTypeSection = self.sportTypeSection {
                let sportObject = sportTypeSection.sportObjects[indexPath.row]
                self.output.didTapShow(detail: sportObject)
                self.delegate?.didSelect(sport: sportObject)
            }
        }
    }
}
