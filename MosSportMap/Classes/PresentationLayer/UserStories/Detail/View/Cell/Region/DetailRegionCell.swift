//
//  DetailRegionCell.swift
//  MosSportMap
//
//  Created by Sergeyd on 15.10.2021.
//

import UIKit

class DetailRegionCell: TableViewCell {

    @IBOutlet var regionTitle: UIButton!
    @IBOutlet var regionPeopes: UILabel!
    @IBOutlet var regionSquare: UILabel!

    //MARK: Func
    func configure(with report: SquareReport) {
        self.regionTitle.setTitle(report.population.area, for: .normal)
        let population = Int(report.population.population)
        self.regionPeopes.text = population.peoples() + " на км²"
        let square = report.population.square / gSquareToKilometers 
        self.regionSquare.text = square.formattedWithSeparator + " км²"
    }
}

extension Int {
    func peoples() -> String {
        var dayString: String!
        if "1".contains("\(self % 10)") { dayString = "Человек" }
        if "234".contains("\(self % 10)") { dayString = "Человека" }
        if "567890".contains("\(self % 10)") { dayString = "Людей" }
        if 11...14 ~= self % 100 { dayString = "Людей" }
        return "\(self) " + dayString
    }
}

extension Int {
    func departments() -> String {
        var dayString: String!
        if "1".contains("\(self % 10)") { dayString = "Департамент" }
        if "234".contains("\(self % 10)") { dayString = "Департамента" }
        if "567890".contains("\(self % 10)") { dayString = "Департаментов" }
        if 11...14 ~= self % 100 { dayString = "Департаментов" }
        return "\(self) " + dayString
    }
}
