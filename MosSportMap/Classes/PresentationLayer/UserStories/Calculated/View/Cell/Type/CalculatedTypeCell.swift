//
//  CalculatedTypeCell.swift
//  MosSportMap
//
//  Created by Sergeyd on 15.10.2021.
//

import Squircle

enum CalculateAreaType: Int {
    case borders = 0
    case hands = 1
    case recommendation
}

protocol CalculatedTypeDelegate: AnyObject {
    func didSelect(calculated type: CalculateAreaType)
    func didTapClearBorders()
}

class CalculatedTypeCell: TableViewCell {

    @IBOutlet var typeDescription: UILabel!
    @IBOutlet var typeButtons: [UIButton]!
    @IBOutlet var clearButton: UIButton!

    weak var delegate: CalculatedTypeDelegate?
    private var selectedType: CalculateAreaType = .borders
    
    // MARK: Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.updateType()
    }
    
    // MARK: Func
    func configure(with borders: [Detail]) {
        let isEnabled = !borders.isEmpty
        self.clearButton.isEnabled = isEnabled
        self.clearButton.backgroundColor = isEnabled ? AppStyle.color(for: .title) : AppStyle.color(for: .background)
    }
    
    // MARK: Private func
    private func updateType() {
        self.typeDescription.text = self.selectedType == .borders ?
        "Выберите на карте район, для которого необходимо произвести расчёт." :
        "Укажите вручную границы, в пределах которых необходимо произвести расчёт. Точка за точкой."
        for button in self.typeButtons {
            if (button.tag == 0) {
                button.backgroundColor = self.selectedType == .borders ? AppStyle.color(for: .coloured) : AppStyle.color(for: .background)
                button.setTitleColor(self.selectedType == .borders ? AppStyle.color(for: .main) : AppStyle.color(for: .coloured), for: .normal)
            } else {
                button.backgroundColor = self.selectedType == .hands ? AppStyle.color(for: .coloured) : AppStyle.color(for: .background)
                button.setTitleColor(self.selectedType == .hands ? AppStyle.color(for: .main) : AppStyle.color(for: .coloured), for: .normal)
            }
        }
    }
    
    // MARK: Action
    @IBAction func didSelectType(sender: UIButton) {
        self.selectedType = CalculateAreaType(rawValue: sender.tag)!
        self.updateType()
        self.delegate?.didSelect(calculated: self.selectedType)
    }
    
    @IBAction func didTapClearBorders() {
        self.delegate?.didTapClearBorders()
    }
}
