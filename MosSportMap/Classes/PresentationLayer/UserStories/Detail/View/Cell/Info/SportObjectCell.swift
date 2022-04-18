//
//  InfoCell.swift
//  MosSportMap
//
//  Created by Sergeyd on 17.10.2021.
//

import UIKit

protocol SportObjectDelegate: AnyObject {
    func didTapShowDepartment(sport object: SportObject)
    func didTapShowSports(sport object: SportObject)
    func didTapObjectsAround(sport object: SportObject)
    func didTapShowOnMap(sport object: SportObject)
}

class SportObjectCell: TableViewCell {

    @IBOutlet var idLabel: UILabel!
    @IBOutlet var titleButton: UIButton!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var availabilityLabel: UILabel!
    @IBOutlet var department: UIButton!
    @IBOutlet var sportsButton: UIButton!
    @IBOutlet var sportsButtonHeight: NSLayoutConstraint!

    weak var delegate: SportObjectDelegate?
    private var object: SportObject!

    // MARK: Func
    func configure(with object: SportObject, isObjectsAroundHidden: Bool) {
        self.object = object
        self.idLabel.text = "Идентификатор объекта: \(object.id)"
        let count = object.sport.count
        self.sportsButton.setTitle("\(count.objects()). Подробнее", for: .normal)
        self.addressLabel.text = object.address
        self.availabilityLabel.text = object.availabilityType.rawValue
        self.titleButton.setTitle(object.title, for: .normal)
        self.department.setTitle(object.department.title, for: .normal)
    }

    // MARK: Action
    @IBAction func didTapDepartment(sender: UIButton) {
        self.delegate?.didTapShowDepartment(sport: self.object)
    }

    @IBAction func didTapSports(sender: UIButton) {
        self.delegate?.didTapShowSports(sport: self.object)
    }

    @IBAction func didTapObjectsAround(sender: UIButton) {
        self.delegate?.didTapObjectsAround(sport: self.object)
    }

    @IBAction func didTapShowOnMap(sender: UIButton) {
        self.delegate?.didTapShowOnMap(sport: self.object)
    }
}
