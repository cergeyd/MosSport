//
//  DetailDetailViewController.swift
//  MosSportMap
//
//  Created by sergiusX on 15/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import UIKit

struct DetailSection {
    let title: String
    let details: [Detail]
}

struct Detail {
    let type: DetailType
    let title: String
    let place: String
    let subtitle: String
}

enum DetailType {
    case region
    case population
}

class DetailViewController: UITableViewController {

    var output: DetailViewOutput!
    var report: SquareReport!
    var sections: [DetailSection] = []

    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.output.didLoadView()
        self.configureSection()
        self.configureTableView()
    }
    
    //MARK: Private func
    private func configureTableView() {
        self.tableView = UITableView(frame: .zero, style: .insetGrouped)
        self.tableView.register(UINib(nibName: DetailRegionCell.identifier, bundle: nil), forCellReuseIdentifier: DetailRegionCell.identifier)
        self.tableView.register(UINib(nibName: DetailCell.identifier, bundle: nil), forCellReuseIdentifier: DetailCell.identifier)
    }

    private func configureSection() {
        let region = Detail(type: .region, title: self.report.population.area, place: "", subtitle: "Данные о районе")
        let rq = DetailSection(title: "Район 1", details: [region])
        self.sections.append(rq)

        let population = Detail(type: .population, title: self.report.population.population.formattedWithSeparator, place: "21 место по Москве", subtitle: "Плотность населения на квадратный километр:")
        let r = DetailSection(title: "Район", details: [population])

        self.sections.append(r)
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
            cell.configure(with: self.report)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: DetailCell.identifier, for: indexPath) as! DetailCell
            cell.accessoryType = .disclosureIndicator
            cell.configure(with: detail)
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 1) {
            let section = self.sections[indexPath.section]
            let detail = section.details[indexPath.row]
            self.output.didTapShow(detail: detail)
        }
    }
}
