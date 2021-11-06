//
//  RecommendationRecommendationViewController.swift
//  MosSportMap
//
//  Created by sergiusX on 21/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import GoogleMapsUtils

protocol RecommendationDelegate: AnyObject {
    func didSelect(calculated type: CalculateAreaType?)
    func didCalculate(recommendation: Recommendation)
    func didSelect(population: Population, polygon: GMSPolygon)
}

class RecommendationViewController: TableViewController {

    var output: RecommendationViewOutput!
    //var type: MenuType!
    weak var delegate: RecommendationDelegate?
    var recommendationType: RecommendationType = .area
    private var sections: [DetailSection] = []
    private var filterDetails: [Detail] = []

    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.output.didLoadView()
        self.configureTableView()
        self.configureSections()
    }

    //MARK: Private func
    private func configureTableView() {
        self.tableView = UITableView(frame: .zero, style: .insetGrouped)
        self.tableView.register(UINib(nibName: DetailCell.identifier, bundle: nil), forCellReuseIdentifier: DetailCell.identifier)
    }

    private func configureSections() {
        switch self.recommendationType {
        case .area:
            var details: [Detail] = []
            self.title = "Укажите район"
            self.delegate?.didSelect(calculated: .recommendation)
            for population in gPopulationResponse.populations {
                let populationValue = Int(population.population)
                let square = population.square / gSquareToKilometers
                details.append(Detail(type: .filter, title: population.area, place: populationValue.peoples() + "/км²", subtitle: "Площадь района: \(square.formattedWithSeparator + " км²")"))
            }
            self.sections.append(DetailSection(title: "Районы", details: details))
        case .availability(let area, _):
            var details: [Detail] = []
            self.title = area.area
            details.append(Detail(type: .filter, title: "Шаговая доступность", place: "", subtitle: "В радиусе 500 м."))
            details.append(Detail(type: .filter, title: "Районное", place: "", subtitle: "В радиусе 1000 м."))
            details.append(Detail(type: .filter, title: "Окружное", place: "", subtitle: "В радиусе 3000 м."))
            details.append(Detail(type: .filter, title: "Городское", place: "", subtitle: "В радиусе 5000 м."))
            self.sections.append(DetailSection(title: "Доступность", details: details))
        case .objects(let area, let availability, let recommendations):
            self.title = "Рекомендация"
            self.delegate?.didCalculate(recommendation: recommendations)
            /// Регион
            let populationValue = Int(area.population)
            let square = area.square / gSquareToKilometers
            let area = Detail(type: .filter, title: area.area, place: populationValue.peoples() + "/км²", subtitle: "Площадь района: \(square.formattedWithSeparator + " км²")")
            /// Доступность
            let range = SharedManager.shared.meters(for: availability)
            let availability = Detail(type: .filter, title: availability.rawValue, place: "Всего: \(recommendations.existObjects.count.objects())", subtitle: "В радиусе \(range) м.")
            /// Отсутствующие виды спорта
            var details: [Detail] = []
            for missing in recommendations.missingTypes {
                details.append(Detail(type: .filter, title: missing.title, place: "Идентификатор: \(missing.id)", subtitle: "Вид спорта"))
            }

            self.sections.append(DetailSection(title: "Регион", details: [area]))
            self.sections.append(DetailSection(title: "Доступность", details: [availability]))
            self.sections.append(DetailSection(title: "Отсутствующие виды спорта", details: details))
        }
    }

    //MARK: Search
    override func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text?.lowercased() {
            self.isSearchActive = !text.isEmpty
            let details = self.sections.flatMap({ $0.details })
            self.filterDetails = details.filter({ (detail) -> Bool in
                let byTitle = detail.title.lowercased().contains(text)
                let byPlace = detail.place.lowercased().contains(text)
                let bySubTitle = detail.subtitle.lowercased().contains(text)
                return byTitle || bySubTitle || byPlace
            })
        }
        self.tableView.reloadData()
    }
}

extension RecommendationViewController: RecommendationViewInput {

    func setupInitialState() {
        self.navigationItem.searchController = self.searchController
        self.navigationBar(isLoading: false)
    }
}

//MARK: TableView
extension RecommendationViewController: MapViewDataSource {

    func didSelect(polygon: GMSPolygon) {
        if let population = SharedManager.shared.population(by: polygon.title) {
            self.output.didSelect(recommendationType: .availability(area: population, polygon: polygon))
        }
    }

    private func detail(at indexPath: IndexPath) -> Detail {
        if (self.isSearchActive) { return self.filterDetails[indexPath.row] }
        return self.sections[indexPath.section].details[indexPath.row]
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        if (self.isSearchActive) { return 1 }
        return self.sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.isSearchActive) { return self.filterDetails.count }
        return self.sections[section].details.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (self.isSearchActive) { return "Результаты:" }
        return self.sections[section].title
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let detailCell = tableView.dequeueReusableCell(withIdentifier: DetailCell.identifier) as! DetailCell
        let item = self.detail(at: indexPath)
        detailCell.configure(with: item, indexPath: indexPath)
        switch self.recommendationType {
        case .objects:
            detailCell.accessoryType = .none
        default:
            detailCell.accessoryType = .disclosureIndicator
        }
        return detailCell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.navigationBar(isLoading: true)
        switch self.recommendationType {
        case .area:
            let area = self.detail(at: indexPath)
            if let population = SharedManager.shared.population(by: area.title), let polygon = SharedManager.shared.polygon(by: population) {
                self.delegate?.didSelect(population: population, polygon: polygon)
                self.output.didSelect(recommendationType: .availability(area: population, polygon: polygon))
            }
        case .availability(area: let area, polygon: let polygon):
            self.navigationBar(isLoading: true)
            Dispatch.after {
                let availability = self.detail(at: indexPath)
                if let type = SportObject.AvailabilityType.init(rawValue: availability.title) {
                    let recommendation = SharedManager.shared.calculateRecommendation(in: polygon, availabilityType: type)
                    self.output.didSelect(recommendationType: .objects(area: area, availability: type, recommendation: recommendation))
                }
                self.navigationBar(isLoading: false)
            }
        case .objects:
            break
        }
    }
}
