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
}

class CalculatedViewController: UITableViewController {

    struct Config {
        static let animationDuration = 0.4
        static let width = 0.5
    }
    
    var type: MenuType!
    var output: CalculatedViewOutput!
    weak var delegate: CalculatedDelegate?
    var report: SquareReport?

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
        self.delegate?.didSelect(calculated: .borders)
        if (self.report != nil) {
            self.report = nil
            self.tableView.reloadData()
        }
        UIView.animate(withDuration: Config.animationDuration) {
            self.splitViewController?.preferredPrimaryColumnWidthFraction = Config.width
        }
    }

    //MARK: Private func
    private func configureTableView() {
        self.tableView = UITableView(frame: .zero, style: .insetGrouped)
        self.tableView.register(UINib(nibName: CalculatedTypeCell.identifier, bundle: nil), forCellReuseIdentifier: CalculatedTypeCell.identifier)
        self.tableView.register(UINib(nibName: CalculatedAreaCell.identifier, bundle: nil), forCellReuseIdentifier: CalculatedAreaCell.identifier)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.report == nil ? 1 : 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Способ выбора области" : "Отчёт"
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            let calculatedType = tableView.dequeueReusableCell(withIdentifier: CalculatedTypeCell.identifier) as! CalculatedTypeCell
            calculatedType.delegate = self
            return calculatedType
        } else {
            let calculatedArea = tableView.dequeueReusableCell(withIdentifier: CalculatedAreaCell.identifier) as! CalculatedAreaCell
            calculatedArea.delegate = self
            calculatedArea.configure(with: self.report!, type: self.type)
            return calculatedArea
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
    
    func didCalculated(report: SquareReport) {
        self.report = report
        self.tableView.reloadData()
        Hud.hide()
    }

    func didSelect(calculated type: CalculateAreaType?) {
        self.delegate?.didSelect(calculated: type)
    }
}
