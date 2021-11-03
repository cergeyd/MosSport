//
//  SettingsCell.swift
//  MosSportMap
//
//  Created by Sergey D on 03.11.2021.
//

import UIKit

protocol SettingsCellDelegate: AnyObject {
    func didUpdateAdditioOSMObjects()
}

class OSMSettingsCell: TableViewCell {
    
    @IBOutlet var OSMswitch: UISwitch!
    
    weak var delegate: SettingsCellDelegate?

    //MARK: Func
    func configure(with isOSM: Bool) {
        self.OSMswitch.setOn(isOSM, animated: true)
    }

    //MARK: Action
    @IBAction func didChangeSwitch(sender: UISwitch) {
        self.delegate?.didUpdateAdditioOSMObjects()
    }
}
