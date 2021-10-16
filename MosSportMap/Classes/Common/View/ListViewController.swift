//
//  ListViewController.swift
//  MosSportMap
//
//  Created by Sergeyd on 16.10.2021.
//

import UIKit

enum ListType {
    case details(detail: Detail)
}

class ListViewController: UITableViewController {

    var type: ListType!
    var details: [Detail] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView = UITableView(frame: .zero, style: .insetGrouped)
        self.tableView.register(UINib(nibName: DetailCell.identifier, bundle: nil), forCellReuseIdentifier: DetailCell.identifier)
        self.configureType()
        super.viewDidLoad()

        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "id")
        self.navigationItem.title = "Меню"
      //  self.navigationController?.navigationBar.prefersLargeTitles = true
    }

    private func configureType() {
        switch self.type {
        case .details(let detail):
            switch detail.type {
            case .population:
                for (ind, population) in populationResponse.populations.enumerated() {
                    self.details.append(Detail(type: detail.type, title: population.area, place: "\(String(ind)) Место", subtitle: population.population.formattedWithSeparator))
                }
            default: break
            }
        default: break
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.details.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let detailCell = tableView.dequeueReusableCell(withIdentifier: DetailCell.identifier) as! DetailCell
        detailCell.configure(with: self.details[indexPath.row])
        return detailCell
    }
}
