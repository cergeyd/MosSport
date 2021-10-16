//
//  MenuMenuViewController.swift
//  MosSportMap
//
//  Created by sergiusX on 15/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import UIKit

struct MenuSection {
    let title: String
    let items: [MenuItem]
}

struct MenuItem {
    let title: String
    let subtitle: String
    let isDetailed: Bool
    let type: MenuType
}

enum MenuType: Int {
    case clear = 0
    case objects = 1
    case heatMap = 2
    case population = 3

    case calculateSportSquare = 10
    case calculateSportCount = 11
    case calculateSportType = 12

}

protocol MenuDelegate: AnyObject {
    func addToDataSource(controller: MapViewDataSource)
    func didUpdate(map type: MenuType)
    func didSelect(calculated type: CalculateAreaType?)
    func didTapShow(detail report: SquareReport)
}

class MenuViewController: UITableViewController {

    struct Config {
        static let width = 0.5
        static let smallWidth = 0.35
        static let animationDuration = 0.4
    }
    
    var output: MenuViewOutput!
    weak var delegate: MenuDelegate?
    
    /// Контроллер с вычислениями, храним так, чтобы удобно было добавить в dataSource
    lazy var calculatedViewController = self.output.calculatedViewController()
    /// Меню
    let sections = [
        MenuSection(title: "Карта", items: [
            MenuItem(title: "Очистить", subtitle: "Карта без каких-либо данных", isDetailed: false, type: .clear),
            MenuItem(title: "Объекты на карте", subtitle: "Спортивная инфраструктура на карте", isDetailed: false, type: .objects),
            MenuItem(title: "Тепловая карта", subtitle: "Спортивная инфраструктура, отображаются при помощи цвета", isDetailed: false, type: .heatMap),
            MenuItem(title: "Границы районов Москвы", subtitle: "Границы районов Москвы с учётом плотности населения", isDetailed: false, type: .population),
            ]),
        MenuSection(title: "Расчёты", items: [
            MenuItem(title: "Площадь спортивных зон", subtitle: "Расчет площади спортивных зон на одного человека на выбранной территории", isDetailed: true, type: .calculateSportSquare),
            MenuItem(title: "Количества спортивных зон", subtitle: "Расчет количества спортивных зон на одного человека на выбранной территории", isDetailed: true, type: .calculateSportCount),
            MenuItem(title: "Количества видов спортивных услуг", subtitle: "расчет количества видов спортивных услуг на одного человека на выбранной территории", isDetailed: true, type: .calculateSportType)
            ])
    ]
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        self.configureTableView()
        super.viewDidLoad()
        self.output.didLoadView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.splitWidth(isSmall: true)
    }
    
    //MARK: Private func
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
        default:
            break
        }
         // let controller = UIViewController()
         // self.showDetailViewController(UINavigationController(rootViewController: controller), sender: nil)
    }
}

extension MenuViewController: CalculatedDelegate {
    
    func didTapShow(detail report: SquareReport) {
        self.delegate?.didTapShow(detail: report)
    }

    func didSelect(calculated type: CalculateAreaType?) {
        self.delegate?.didSelect(calculated: type)
    }
}
