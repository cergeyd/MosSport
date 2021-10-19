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
    case sportTypes
    case population
    case sportObjects
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
    private var sections: [DetailSection] = []
    weak var delegate: DetailViewDelegate?

    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.output.didLoadView()
        /// Отчёт                                                                                                                                                                /// Объекты депртамента
        if let report = self.report { self.configureSection(with: report) } else if let section = self.section { self.configureSection(with: section) }
        self.configureTableView()
        self.rightNavigationBar()
    }

    //MARK: Private func
    private func rightNavigationBar(isLoading: Bool = false) {
        if (isLoading) {
            self.navigationActivity()
        } else {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(didTapExport))
        }
    }

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

    private func configureSection(with departmentSection: DepartmentSection) {
        var details: [Detail] = []
        for sportObject in departmentSection.sportObjects {
            let detail = Detail(type: .population, title: sportObject.title, place: sportObject.address, subtitle: "sports")
            details.append(detail)
        }
        let populationSection = DetailSection(title: "Население", details: details)
        self.sections.append(populationSection)
    }

    private func configureSection(with report: SquareReport) {
        let region = Detail(type: .region, title: report.population.area, place: "", subtitle: "Данные о районе")
        let area = DetailSection(title: "Район", details: [region])
        self.sections.append(area)

        /// Плотность населения
        let population = Detail(type: .population, title: report.population.population.formattedWithSeparator, place: "\(report.placeBySquare) место по Москве", subtitle: "Плотность населения на квадратный километр:")
        let populationSection = DetailSection(title: "Население", details: [population])

        /// Площадат района
        let square = Detail(type: .square, title: (report.population.square / gSquareToKilometers).formattedWithSeparator + " км²", place: "\(report.placeBySquare) место по Москве", subtitle: "Площадь района:")
        let squareSportObjects = Detail(type: .sportSquare, title: (report.allSquare / gSquareToKilometers).formattedWithSeparator + " км²", place: "\(report.placeBySquare) место по Москве", subtitle: "Площадь спортивных объектов:")
        let squareForOne = Detail(type: .squareForOne, title: report.squareForOne.formattedWithSeparator + " м²", place: "\(report.placeBySquare) место по Москве", subtitle: "Площадь спортивных объектов на человека:")
        let objectForOne = Detail(type: .objectForOne, title: report.sportForOne.formattedWithSeparator + " объекта", place: "\(report.placeBySquare) место по Москве", subtitle: "Спортивные объекты для одного человека:")
        let sportTypeForOne = Detail(type: .sportTypeForOne, title: report.sportTypeForOne.formattedWithSeparator + " типа", place: "\(report.placeBySquare) место по Москве", subtitle: "Типы спорта для одного человека:")
        let sqareSection = DetailSection(title: "Площадь", details: [square, squareSportObjects, squareForOne, objectForOne, sportTypeForOne])

        /// Департаменты района
        let departments = Detail(type: .department, title: report.departments.count.departments(), place: "\(report.placeBySquare) место по Москве", subtitle: "Департаменты района:")
        let departmentsSection = DetailSection(title: "Департаменты", details: [departments])

        /// Виды спортивных площадок
        let sportTypes = Detail(type: .sportTypes, title: "\(report.sportTypes.count) Вида игр", place: "\(report.placeBySquare) место по Москве", subtitle: "Типы спортивных объектов:")

        /// Cпортивные площадки в районе
        let sports = Detail(type: .sportObjects, title: "\(report.objects.count) Площадок", place: "\(report.placeBySquare) место по Москве", subtitle: "Cпортивныe объекты в районе:")
        let sportsSection = DetailSection(title: "Спортивные объекты", details: [sportTypes, sports])

        self.sections.append(populationSection)
        self.sections.append(sqareSection)
        self.sections.append(departmentsSection)
        self.sections.append(sportsSection)
    }
}

extension DetailViewController: DetailViewInput {

    func setupInitialState() {
        self.navigationItem.title = "Детали"
    }
}

//MARK: TableView
extension DetailViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections[section].details.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section].title
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = self.sections[indexPath.section]
        let detail = section.details[indexPath.row]
        switch detail.type {
        case .region:
            let cell = tableView.dequeueReusableCell(withIdentifier: DetailRegionCell.identifier, for: indexPath) as! DetailRegionCell
            cell.configure(with: self.report!)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: DetailCell.identifier, for: indexPath) as! DetailCell
            cell.configure(with: detail, indexPath: indexPath)
            let isDisclosure = indexPath.section > 2
            cell.accessoryType = isDisclosure ? .disclosureIndicator : .none
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /// Отчёт
        if (indexPath.section > 0) {
            let section = self.sections[indexPath.section]
            let detail = section.details[indexPath.row]
            self.output.didTapShow(detail: detail, report: self.report!)
        } else {
            /// Игры департамента
            if let section = self.section {
                let sportObject = section.sportObjects[indexPath.row]
                self.output.didTapShow(detail: sportObject)
                self.delegate?.didSelect(sport: sportObject)
            }
        }
    }
}
