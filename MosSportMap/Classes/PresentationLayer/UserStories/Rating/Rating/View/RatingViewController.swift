//
//  RatingRatingViewController.swift
//  MosSportMap
//
//  Created by Sergey D on 02/11/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import Pageboy

class RatingViewController: TableViewController {

    var output: RatingViewOutput!
    var type: RateType!

    private var details: [Detail] = []

    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.output.didLoadView()
        self.configureDetails()
    }

    //MARK: Funcs
    func configureDetails(isAscending: Bool = true) {
        self.details.removeAll()
        switch self.type! {
        case .squareForOne:
            var sorted = gPopulationResponse.populations.sorted(by: { $0.rating.placeBySquareForOne < $1.rating.placeBySquareForOne })
            if (!isAscending) { sorted.reverse() }
            for (ind, population) in sorted.enumerated() {
                let detail = Detail(type: .square, title: population.area, place: "Место: \(ind + 1)", subtitle: "Значение: \(population.rating.placeBySquareForOneValue)")
                self.details.append(detail)
            }
        case .sportForOne:
            var sorted = gPopulationResponse.populations.sorted(by: { $0.rating.placeBySportForOne < $1.rating.placeBySportForOne })
            if (!isAscending) { sorted.reverse() }
            for (ind, population) in sorted.enumerated() {
                let detail = Detail(type: .square, title: population.area, place: "Место: \(ind + 1)", subtitle: "Значение: \(population.rating.placeBySportForOneValue)")
                self.details.append(detail)
            }
        case .objectForOne:
            var sorted = gPopulationResponse.populations.sorted(by: { $0.rating.placeByObjectForOne < $1.rating.placeByObjectForOne })
            if (!isAscending) { sorted.reverse() }
            for (ind, population) in sorted.enumerated() {
                let detail = Detail(type: .square, title: population.area, place: "Место: \(ind + 1)", subtitle: "Значение: \(population.rating.placeByObjectForOneValue)")
                self.details.append(detail)
            }
        }
        self.tableView.reloadData()
    }
    
    //MARK: Private func
    private func configureTableView() {
        self.tableView = UITableView(frame: .zero, style: .insetGrouped)
        self.tableView.register(UINib(nibName: DetailCell.identifier, bundle: nil), forCellReuseIdentifier: DetailCell.identifier)
    }

    //MARK: TableView
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.details.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch self.type! {
        case .squareForOne:
            return "Площадь спортивных объектов на среднюю плотность населения"
        case .sportForOne:
            return "Виды спорта на среднюю плотность населения"
        case .objectForOne:
            return "Спортивные объекты на среднюю плотность населения"
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DetailCell.identifier, for: indexPath) as! DetailCell
        let detail = self.details[indexPath.row]
        cell.configure(with: detail, indexPath: indexPath)
        return cell
    }
}

extension RatingViewController: RatingViewInput {

    func setupInitialState() {
        self.configureTableView()
    }
}
