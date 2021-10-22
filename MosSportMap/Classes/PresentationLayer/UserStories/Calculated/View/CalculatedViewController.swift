//
//  CalculatedCalculatedViewController.swift
//  MosSportMap
//
//  Created by sergiusX on 15/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import UIKit

protocol CalculatedDelegate: AnyObject {
    func didSelect(calculated type: CalculateAreaType?)
    func didTapShow(detail report: SquareReport)
    func didTapClearBorders()
}

class CalculatedViewController: TableViewController {

    struct Config {
        static let animationDuration = 0.4
        static let width = 0.5
    }

    var output: CalculatedViewOutput!
    var type: MenuType!
    weak var delegate: CalculatedDelegate?
    var report: SquareReport?
    private var calculateAreaType: CalculateAreaType = .borders
    /// Текущие границы, указанные пользователем на экране Карт
    private var borders: [Detail] = []

    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureTableView()
        self.output.didLoadView()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        /// Ушли с экрана - рассказали
        self.delegate?.didSelect(calculated: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIView.animate(withDuration: Config.animationDuration) {
            self.splitViewController?.preferredPrimaryColumnWidthFraction = Config.width
        }
        self.delegate?.didSelect(calculated: self.calculateAreaType)
        if let lastSelectedAreaReport = lastSelectedAreaReport {
            self.didCalculated(report: lastSelectedAreaReport)
        } else {
            if (self.report != nil) {
                self.report = nil
                self.tableView.reloadData()
            }
        }
    }

    //MARK: Private func
    private func configureTableView() {
        self.tableView = UITableView(frame: .zero, style: .insetGrouped)
        self.tableView.register(UINib(nibName: CalculatedTypeCell.identifier, bundle: nil), forCellReuseIdentifier: CalculatedTypeCell.identifier)
        self.tableView.register(UINib(nibName: CalculatedAreaCell.identifier, bundle: nil), forCellReuseIdentifier: CalculatedAreaCell.identifier)
        self.tableView.register(UINib(nibName: DetailCell.identifier, bundle: nil), forCellReuseIdentifier: DetailCell.identifier)
    }

    //MARK: TableView
    override func numberOfSections(in tableView: UITableView) -> Int {
        switch self.calculateAreaType {
        case .borders: return self.report == nil ? 1 : 2
        default: return self.report == nil ? 2 : 3
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.calculateAreaType {
        case .borders: return 1
        default: return section == 1 ? self.borders.count : 1
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch self.calculateAreaType {
        case .borders: return section == 0 ? "Способ выбора области" : "Отчёт"
        default: return section == 0 ? "Способ выбора области" : section == 1 ? "Границы" : "Отчёт"
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.section == 0) {
            switch self.calculateAreaType {
            case .borders: return 180.0
            default: return 240.0
            }
        }
        return UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            let calculatedType = tableView.dequeueReusableCell(withIdentifier: CalculatedTypeCell.identifier) as! CalculatedTypeCell
            calculatedType.delegate = self
            calculatedType.configure(with: self.borders)
            return calculatedType
        }
        switch self.calculateAreaType {
        case .borders:
            let calculatedArea = tableView.dequeueReusableCell(withIdentifier: CalculatedAreaCell.identifier) as! CalculatedAreaCell
            calculatedArea.delegate = self
            calculatedArea.configure(with: self.report!, type: self.type, borders: self.borders)
            return calculatedArea
        default:
            if (indexPath.section == 1) {
                let cell = tableView.dequeueReusableCell(withIdentifier: DetailCell.identifier, for: indexPath) as! DetailCell
                var border = self.borders[indexPath.row]
                border.subtitle = "Граница № \(indexPath.row + 1)"
                cell.configure(with: border, indexPath: indexPath)
                return cell
            } else {
                let calculatedArea = tableView.dequeueReusableCell(withIdentifier: CalculatedAreaCell.identifier) as! CalculatedAreaCell
                calculatedArea.delegate = self
                calculatedArea.configure(with: self.report!, type: self.type, borders: self.borders)
                return calculatedArea
            }
        }
    }
}

extension CalculatedViewController: CalculatedViewInput, CalculatedAreaDelegate {

    func setupInitialState() {
        self.navigationItem.title = "Меню"
    }

    func didTapShow(detail report: SquareReport) {
        self.delegate?.didTapShow(detail: report)
    }
}

extension CalculatedViewController: CalculatedTypeDelegate, MapViewDataSource {

    func didTapClearBorders() {
        self.borders.removeAll()
        self.delegate?.didTapClearBorders()
        self.tableView.reloadData()
    }

    func didSelect(border: Detail) {
        self.borders.append(border)
        self.tableView.reloadData()
    }

    func didCalculated(report: SquareReport) {
        self.report = report
        self.tableView.reloadData()
    }

    func didSelect(calculated type: CalculateAreaType) {
        self.calculateAreaType = type
        self.report = nil
        self.delegate?.didSelect(calculated: type)
        self.tableView.reloadData()
    }
}
