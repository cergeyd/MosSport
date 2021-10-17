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
        self.regionPeopes.text = report.population.population.formattedWithSeparator
        self.regionSquare.text = report.population.square.formattedWithSeparator 
    }
}
