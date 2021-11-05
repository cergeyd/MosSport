//
//  MenuMenuViewController.swift
//  MosSportMap
//
//  Created by sergiusX on 15/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import GoogleMapsUtils

enum MenuType: Int {
    case clear = 0
    case objects = 1
    case heatMap = 2
    case population = 3
    /// Расчёты
    case calculateSportSquare = 10
    case calculateSportCount = 11
    case calculateSportType = 12
    /// Фильтрация
    case filterDepartments = 20
    case filterAreas = 21
    case filterObjects = 22
    case filterSportTypes = 23
    /// Рекомендации
    case recNewObjects = 30
    case recNewRating = 31
}

protocol MenuDelegate: AnyObject {
    func addToDataSource(controller: MapViewDataSource)
    func didUpdate(map type: MenuType)
    func didSelect(calculated type: CalculateAreaType?)
    func didTapShow(detail report: SquareReport)
    func didTapShowRating()
    func didSelect(population: Population)
    func didSelect(department: Department)
    func didTapShow(type: SportType, objects: [SportObject])
    func didSelect(filter sport: SportObject)
    func didTapClearBorders()
    func didCalculate(recommendation: Recommendation)
    func didSelect(population: Population, polygon: GMSPolygon)
}

class MenuViewController: TableViewController {

    struct Config {
        static let width = 0.5
        static let smallWidth = 0.35
        static let animationDuration = 0.4
    }

    var output: MenuViewOutput!
    weak var delegate: MenuDelegate?
    /// Контроллеры, храним так, чтобы удобно было добавить в dataSource
    lazy var calculatedViewController = self.output.calculatedViewController()
    lazy var recommendationViewController = self.output.recommendationViewController()
    /// Меню
    let sections = [
        MenuSection(title: "Карта", items: [
            MenuItem(title: "Очистить", subtitle: "Карта без каких-либо данных", isDetailed: false, type: .clear),
            MenuItem(title: "Объекты на карте", subtitle: "Спортивная инфраструктура на карте", isDetailed: false, type: .objects),
            MenuItem(title: "Тепловая карта", subtitle: "Спортивная инфраструктура, отображается при помощи цвета", isDetailed: false, type: .heatMap),
            MenuItem(title: "Границы районов Москвы", subtitle: "Границы районов Москвы с учётом плотности населения", isDetailed: false, type: .population),
            ]),
        MenuSection(title: "Расчёты", items: [
            MenuItem(title: "Площадь спортивных зон", subtitle: "Расчет площади спортивных зон на одного человека на выбранной территории", isDetailed: true, type: .calculateSportSquare),
            MenuItem(title: "Количества спортивных зон", subtitle: "Расчет количества спортивных зон на одного человека на выбранной территории", isDetailed: true, type: .calculateSportCount),
            MenuItem(title: "Количества видов спортивных услуг", subtitle: "Расчет количества видов спортивных услуг на одного человека на выбранной территории", isDetailed: true, type: .calculateSportType)
            ]),
        MenuSection(title: "Фильтр", items: [
            MenuItem(title: "Департаменты", subtitle: "Фильтрация по принадлежности спортивного объекта к департаменту", isDetailed: true, type: .filterDepartments),
            MenuItem(title: "Районы", subtitle: "Спортивная инфраструктура в районе", isDetailed: true, type: .filterAreas),
            MenuItem(title: "Cпортивные объекты", subtitle: "Фильтрация спортивных объектов", isDetailed: true, type: .filterObjects),
            MenuItem(title: "Виды спортивных услуг", subtitle: "Фильтрация спортивных объектов по видам спорта", isDetailed: true, type: .filterSportTypes)
            ]),
        MenuSection(title: "Рекомендации", items: [
            MenuItem(title: "Новые спортивные объекты", subtitle: "Оснащению территории новыми спортивными объектами", isDetailed: true, type: .recNewObjects),
            MenuItem(title: "Рейтинговая система", subtitle: "Положение района в таблице на основе его данных о спортивных объектах. Районы лидера,а также проблемные районы.", isDetailed: true, type: .recNewRating)
            ])
    ]

    //MARK: Lifecycle
    override func viewDidLoad() {
        self.configureTableView()
        super.viewDidLoad()
        self.output.didLoadView()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Настройки", style: .plain, target: self, action: #selector(didTapSettings))

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.splitWidth(isSmall: true)
        self.delegate?.didSelect(calculated: nil)
    }

    //MARK: Private func
    @objc private func didTapSettings() {
        self.output.didTapSettings()
    }
    
    private func configureTableView() {
        self.tableView = UITableView(frame: .zero, style: .insetGrouped)
        self.tableView.register(MenuCell.self, forCellReuseIdentifier: MenuCell.identifier)
    }

    /// Анимируем ширину меню
    private func splitWidth(isSmall: Bool, completion: (() -> Void)? = nil) {
        let currentWidth = self.splitViewController?.preferredPrimaryColumnWidthFraction
        let needWidth = isSmall ? Config.smallWidth : Config.width
        if (currentWidth != needWidth) {
            UIView.animate(withDuration: Config.animationDuration) {
                self.splitViewController?.preferredPrimaryColumnWidthFraction = isSmall ? Config.smallWidth : Config.width
            } completion: { isComplete in
                if (isComplete) { completion?() }
            }
        }
    }
}

extension MenuViewController: MenuViewInput {

    func setupInitialState() {
        self.navigationItem.title = "Меню"
        self.delegate?.addToDataSource(controller: self.calculatedViewController)
        self.delegate?.addToDataSource(controller: self.recommendationViewController)
    }
}

//MARK: TableView
extension MenuViewController {

    private func menuItem(at indexPath: IndexPath) -> MenuItem {
        self.sections[indexPath.section].items[indexPath.row]
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections[section].items.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section].title
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let menuCell = tableView.dequeueReusableCell(withIdentifier: MenuCell.identifier) as! MenuCell
        let item = self.menuItem(at: indexPath)
        menuCell.accessoryType = item.isDetailed ? .disclosureIndicator : .none
        menuCell.configure(with: item)
        return menuCell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let value = String(indexPath.section) + String(indexPath.row)
        let type = MenuType(rawValue: Int(value)!)!
        switch indexPath.section {
        case 0:
            self.delegate?.didUpdate(map: type)
        case 1:
            self.calculatedViewController.type = type
            self.push(self.calculatedViewController)
        case 3:
            /// Экран с рейтингом
            if (type == .recNewRating) {
                self.delegate?.didTapShowRating()
            } else {
                /// Экран с рекомендациями
                self.recommendationViewController.type = type
                self.push(self.recommendationViewController)
            }
        default:
            self.output.didTapShow(listType: type)
        }
    }
}

extension MenuViewController: CalculatedDelegate, RecommendationDelegate, ListViewDelegate {

    func didSelect(population: Population, polygon: GMSPolygon) {
        self.delegate?.didSelect(population: population, polygon: polygon)
    }

    func didCalculate(recommendation: Recommendation) {
        self.delegate?.didCalculate(recommendation: recommendation)
    }

    func didTapClearBorders() {
        self.delegate?.didTapClearBorders()
    }

    func didSelect(filter sport: SportObject) {
        self.delegate?.didSelect(filter: sport)
    }

    func didTapShow(type: SportType, objects: [SportObject]) {
        self.delegate?.didTapShow(type: type, objects: objects)
    }

    func didSelect(department: Department) {
        self.delegate?.didSelect(department: department)
    }

    func didSelect(population: Population) {
        self.delegate?.didSelect(population: population)
    }

    func didTapShow(detail report: SquareReport) {
        self.delegate?.didTapShow(detail: report)
    }

    func didSelect(calculated type: CalculateAreaType?) {
        self.delegate?.didSelect(calculated: type)
    }
}
