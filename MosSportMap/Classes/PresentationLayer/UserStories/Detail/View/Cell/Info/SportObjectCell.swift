//
//  InfoCell.swift
//  MosSportMap
//
//  Created by Sergeyd on 17.10.2021.
//

import UIKit

class SportObjectCell: TableViewCell {
    
    @IBOutlet var idLabel: UILabel!
    @IBOutlet var titleButton: UIButton!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var availabilityLabel: UILabel!
    @IBOutlet var department: UIButton!

    //MARK: Func
    func configure(with object: SportObject) {
        
    }
    
    //MARK: Action
    @IBAction func didTapDepartment(sender: UIButton) {
        
    }
    
    @IBAction func didTapShowOnMap(sender: UIButton) {
        
    }
}
