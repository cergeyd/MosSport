//
//  CalculatedAreaCell.swift
//  MosSportMap
//
//  Created by Sergeyd on 15.10.2021.
//

import Squircle

protocol CalculatedAreaDelegate: AnyObject {
    func didTapShow(detail report: SquareReport)
}

class CalculatedAreaCell: TableViewCell {

    @IBOutlet var headerLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var areaButton: UIButton!
    @IBOutlet var calculateButton: UIButton!

    @IBOutlet var firstValueDescription: UILabel!
    @IBOutlet var firstValue: UILabel!

    @IBOutlet var secondValueDescription: UILabel!
    @IBOutlet var secondValue: UILabel!

    @IBOutlet var thirdValueDescription: UILabel!
    @IBOutlet var thirdValue: UILabel!

    @IBOutlet var fourthValueDescription: UILabel!
    @IBOutlet var fourthValue: UILabel!

    weak var delegate: CalculatedAreaDelegate?
    private var report: SquareReport!

    //MARK: Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.calculateButton.squircle()
    }

    //MARK: Func
    func configure(with report: SquareReport, type: MenuType, borders: [Detail]) {
        self.report = report
        self.areaButton.setTitle(report.population.area, for: .normal)        
        if (borders.isEmpty) {
            self.headerLabel.text = "Произведён расчёт для территории:"
        } else {
            self.headerLabel.text = "Произведён расчёт для территории, указанной вручную:"
        }
        
        let populationValue = Int(report.population.population)
        self.descriptionLabel.text = "Плотность населения на квадратный километр: \(populationValue.peoples())/км²"

        switch type {
        case .calculateSportSquare:
            self.firstValueDescription.text = "Площадь спортивных зон для данной плотности населения на выбранной территории:"
            self.firstValue.text = report.squareForOne.formattedWithSeparator + " м²"
            self.secondValueDescription.text = "Количество спортивных объектов в регионе:"
            self.secondValue.text = String(report.objects.count)
            self.fourthValueDescription.text = "Количество спортивных зон в регионе:"
            self.fourthValue.text = String(report.sports.count)
            self.thirdValueDescription.text = "Общая площадь спортивных объектов:"
            self.thirdValue.text = (report.allSquare).formattedWithSeparator + " м²"
        case .calculateSportCount:
            self.firstValueDescription.text = "Количество спортивных зон для данной плотности населения на выбранной территории:"
            self.firstValue.text = report.sportForOne.formattedWithSeparator
            self.secondValueDescription.text = "Количество спортивных объектов для данной плотности населения на выбранной территории:"
            self.secondValue.text = report.objectForOne.formattedWithSeparator
            self.fourthValueDescription.text = "Количество спортивных объектов в регионе:"
            self.fourthValue.text = String(report.objects.count)
            self.thirdValueDescription.text = "Количество спортивных зон в регионе:"
            self.thirdValue.text = String(report.sports.count)
        case .calculateSportType:
            self.firstValueDescription.text = "Количества видов спортивных услуг для данной плотности населения на выбранной территории:"
            self.firstValue.text = report.sportTypeForOne.formattedWithSeparator
            self.secondValueDescription.text = "Количество спортивных объектов для данной плотности населения на выбранной территории:"
            self.secondValue.text = report.objectForOne.formattedWithSeparator
            self.fourthValueDescription.text = "Количество спортивных объектов в регионе:"
            self.fourthValue.text = String(report.objects.count)
            self.thirdValueDescription.text = "Количество спортивных зон в регионе:"
            self.thirdValue.text = String(report.sports.count)
        default: break
        }
    }

    //MARK: Action
    @IBAction func didTapCalculating(sender: ActivityButton) {
        self.delegate?.didTapShow(detail: self.report)
    }
}
