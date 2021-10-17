//
//  DetailCell.swift
//  MosSportMap
//
//  Created by Sergeyd on 15.10.2021.
//

import UIKit

class DetailCell: TableViewCell {

    @IBOutlet var detailTitle: UILabel!
    @IBOutlet var detailSubtitle: UILabel!
    @IBOutlet var detailPlace: UILabel!

    //MARK: Func
    func configure(with detail: Detail) {
        self.detailTitle.text = detail.title
        self.detailSubtitle.text = detail.subtitle
        self.detailPlace.text = detail.place
        let isDisclosure = detail.type == .sportObjects || detail.type == .sportTypes || detail.type == .department
        self.accessoryType = isDisclosure ? .disclosureIndicator : .none
    }
}
