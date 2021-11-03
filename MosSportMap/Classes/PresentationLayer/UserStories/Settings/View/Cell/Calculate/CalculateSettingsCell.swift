//
//  CalculateCell.swift
//  MosSportMap
//
//  Created by Sergey D on 03.11.2021.
//

import UIKit

protocol CalculateSettingsCellDelegate: AnyObject {
    func didSetAverage(density: Int?)
}

class CalculateSettingsCell: TableViewCell {

    @IBOutlet var densitySwitch: UISwitch!
    @IBOutlet var densityInput: UITextField!

    weak var delegate: CalculateSettingsCellDelegate?

    //MARK: Func
    func configure(with isAverage: Bool, value: Int? = nil) {
        self.densitySwitch.setOn(isAverage, animated: true)
        if let value = value {
            self.densityInput.text = value.formattedWithSeparator
        }
    }

    //MARK: Action
    @IBAction func didChangeSwitch(sender: UISwitch) {
        if (sender.isOn) {
            self.delegate?.didSetAverage(density: nil)
        } else {
            self.delegate?.didSetAverage(density: Int(gCalculatePerPeoples))
            self.densityInput.text = gCalculatePerPeoples.formattedWithSeparator
        }
    }
}

extension CalculateSettingsCell: UITextFieldDelegate {

    func textFieldDidEndEditing(_ textField: UITextField) {
        if let value = Int(textField.text ?? "") {
            self.delegate?.didSetAverage(density: value)
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
