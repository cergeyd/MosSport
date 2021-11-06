//
//  RecommendationObjectRecommendationObjectViewController.swift
//  MosSportMap
//
//  Created by Sergey D on 06/11/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import GoogleMapsUtils

enum RecommendationSportObjectType {
    case sportTypes
    case availability(type: SportType)
    case populations(type: SportType, avalability: SportObject.AvailabilityType)
    case result(type: SportType, avalability: SportObject.AvailabilityType, population: Population, recommendation: Recommendation)
    case missing(populations: [Population], type: SportType, isMissing: Bool)
}

protocol RecommendationObjectDelegate: AnyObject {
    func needShowAreas()
    func didCalculate(recommendation: Recommendation)
    func didSelect(population: Population, polygon: GMSPolygon)
}

class RecommendationObjectViewController: TableViewController {

    struct Config {
        static let animationDuration = 0.4
        static let width = 0.4
    }

    var output: RecommendationObjectViewOutput!
    var type: MenuType!
    weak var delegate: RecommendationObjectDelegate?
    var recommendationType: RecommendationSportObjectType = .sportTypes
    private var sections: [DetailSection] = []
    private var filterDetails: [Detail] = []

    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.output.didLoadView()
        self.configureTableView()
        self.configureSections()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIView.animate(withDuration: Config.animationDuration) {
            self.splitViewController?.preferredPrimaryColumnWidthFraction = Config.width
        }
    }

    //MARK: Private func
    private func configureTableView() {
        self.tableView = UITableView(frame: .zero, style: .insetGrouped)
        self.tableView.register(UINib(nibName: DetailCell.identifier, bundle: nil), forCellReuseIdentifier: DetailCell.identifier)
    }

    private func configureSections() {
        switch self.recommendationType {
        case .sportTypes:
            var details: [Detail] = []
            self.title = "Укажите вид спорта"
            self.delegate?.needShowAreas()
            for type in gSportTypes.types {
                details.append(Detail(type: .filter, title: type.title, place: "Идентификатор: \(type.id)", subtitle: "Вид спорта"))
            }
            self.sections.append(DetailSection(title: "Районы", details: details))
        case .availability(type: let type):
            self.title = type.title

            /// Отсутствует
            var details: [Detail] = []
            let populations = SharedManager.shared.emptyPopulations(sportType: type)
            details.append(Detail(type: .filter, title: "Районы в которых данный вид спорта отсутствует", place: "", subtitle: populations.count.populations()))
            self.sections.append(DetailSection(title: "Районы, в которых не представлен данный вид спорта", details: details))

            /// Присутствует
            var detailzs: [Detail] = []
            let populationz = SharedManager.shared.existPopulations(sportType: type)
            detailzs.append(Detail(type: .filter, title: "Районы в которых данный вид спорта присутствует", place: "", subtitle: populationz.count.populations()))
            self.sections.append(DetailSection(title: "Районы, в которых представлен данный вид спорта", details: detailzs))

            /// Доступность
            var detailz: [Detail] = []
            detailz.append(Detail(type: .filter, title: "Шаговая доступность", place: "", subtitle: "В радиусе 500 м."))
            detailz.append(Detail(type: .filter, title: "Районное", place: "", subtitle: "В радиусе 1000 м."))
            detailz.append(Detail(type: .filter, title: "Окружное", place: "", subtitle: "В радиусе 3000 м."))
            detailz.append(Detail(type: .filter, title: "Городское", place: "", subtitle: "В радиусе 5000 м."))
            self.sections.append(DetailSection(title: "Доступность нового объекта", details: detailz))
        case .result(type: let type, avalability: let availability, let area, let recommendations):
            self.title = "Рекомендация"
            self.delegate?.didCalculate(recommendation: recommendations)
            /// Регион
            let populationValue = Int(area.population)
            let square = area.square / gSquareToKilometers
            let area = Detail(type: .filter, title: area.area, place: populationValue.peoples() + "/км²", subtitle: "Площадь района: \(square.formattedWithSeparator + " км²")")
            /// Доступность
            let range = SharedManager.shared.meters(for: availability)
            let availability = Detail(type: .filter, title: availability.rawValue, place: "Всего: \(recommendations.existObjects.count.objects())", subtitle: "В радиусе \(range) м.")
            /// Отсутствующие/Присутствующие виды спорта
            var details: [Detail] = []
            for missing in recommendations.missingTypes {
                details.append(Detail(type: .filter, title: missing.title, place: "Идентификатор: \(missing.id)", subtitle: "Вид спорта"))
            }

            self.sections.append(DetailSection(title: "Регион", details: [area]))
            self.sections.append(DetailSection(title: "Доступность", details: [availability]))
            self.sections.append(DetailSection(title: "Отсутствующие виды спорта", details: details))

        case .missing(populations: let populations, type: let type, let isMissing):
            /// Районы, в которых не представлен данный вид спорта
            self.title = "Районы"
            var details: [Detail] = []
            for (ind, population) in populations.enumerated() {
                details.append(Detail(type: .filter, title: population.area, place: String(ind + 1), subtitle: "Плотность населения: " + population.population.formattedWithSeparator))
            }
            self.sections.append(DetailSection(title: isMissing ? "Районы, в которых не представлен данный вид спорта" : "Районы, в которых представлен данный вид спорта", details: details))
        case .populations(type: let type, avalability: let avalability):
            self.title = "Район"
            var details: [Detail] = []
            for (ind, population) in gPopulationResponse.populations.enumerated() {
                details.append(Detail(type: .filter, title: population.area, place: "\(String(ind + 1)) Место", subtitle: population.population.formattedWithSeparator))
            }
            self.sections.append(DetailSection(title: "Укажите конкретный район, для которого необходимо произвести расчёт для оптимального места сооружения нового спортивного объекта", details: details))
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

extension RecommendationObjectViewController: RecommendationObjectViewInput {

    func setupInitialState() {
        self.navigationItem.searchController = self.searchController
        self.navigationBar(isLoading: false)
    }
}

//MARK: TableView
extension RecommendationObjectViewController: MapViewDataSource {

    func didSelect(polygon: GMSPolygon) {
        if let population = SharedManager.shared.population(by: polygon.title) {
            // self.output.didSelect(recommendationType: .availability(area: population, polygon: polygon))
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
        case .result:
            detailCell.accessoryType = .none
        default:
            detailCell.accessoryType = .disclosureIndicator
        }
        return detailCell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.navigationBar(isLoading: true)
        Dispatch.after { self.navigationBar(isLoading: false) }
        let detail = self.detail(at: indexPath)
        switch self.recommendationType {
        case .sportTypes:
            for sportType in gSportTypes.types {
                if (sportType.title == detail.title) {
                    self.output.didSelect(recommendationType: .availability(type: sportType))
                }
            }
        case .availability(type: let type):
            if (indexPath.section == 0) {
                let populations = SharedManager.shared.emptyPopulations(sportType: type)
                self.output.didSelect(recommendationType: .missing(populations: populations, type: type, isMissing: true))
            } else if (indexPath.section == 1) {
                let populations = SharedManager.shared.existPopulations(sportType: type)
                self.output.didSelect(recommendationType: .missing(populations: populations, type: type, isMissing: false))
            } else {
                if let availability = SharedManager.shared.availabilityType(for: detail.title) {
                    self.output.didSelect(recommendationType: .populations(type: type, avalability: availability))
                }
            }
        case .result:
            break
        case .missing(populations: let populations, type: let type, _):
            if let population = SharedManager.shared.population(by: detail.title), let polygon = SharedManager.shared.polygon(by: population) {
                self.delegate?.didSelect(population: population, polygon: polygon)
            }
        case .populations(type: let type, avalability: let avalability):
            if let population = SharedManager.shared.population(by: detail.title), let polygon = SharedManager.shared.polygon(by: population) {
                let recommendation = SharedManager.shared.calculateRecommendation(in: polygon, availabilityType: avalability, sportType: type)
                self.output.didSelect(recommendationType: .result(type: type, avalability: avalability, population: population, recommendation: recommendation))
                self.delegate?.didSelect(population: population, polygon: polygon)
            }
        }
    }

    private func calculateRecommendation(in polygon: GMSPolygon, availabilityType: SportObject.AvailabilityType) -> Recommendation {
        /// Границы региона
        let rectangle = SharedManager.shared.getRectangle(inside: polygon)
        /// Объекты, которые уже есть в регионе
        let objects = SharedManager.shared.objects(for: polygon, with: availabilityType)
        /// Виды спорта, которых не хватает
        let missingTypes = SharedManager.shared.missingSportTypes(objects: objects)
        /// Координаты, где можно разместить объект
        var emptyCoordinates: [CLLocationCoordinate2D] = []
        let range = SharedManager.shared.meters(for: availabilityType)

        for i in stride(from: rectangle.topLeft.longitude, to: rectangle.bottomRight.longitude, by: 0.002) {
            for j in stride(from: rectangle.bottomRight.latitude, to: rectangle.topLeft.latitude, by: 0.001) {
                let missCoordinates = CLLocationCoordinate2D(latitude: j, longitude: i)
                if (polygon.contains(coordinate: missCoordinates)) {
                    var minDistance = 5000.0
                    for object in objects {
                        let existLocation = CLLocation(latitude: object.coordinate.latitude, longitude: object.coordinate.longitude)
                        let missLocation = CLLocation(latitude: missCoordinates.latitude, longitude: missCoordinates.longitude)

                        let distance = existLocation.distance(from: missLocation)
                        if (distance < minDistance) {
                            minDistance = distance
                        }
                    }
                    if (minDistance + 100.0 > range) { /// Сто метров offset
                        emptyCoordinates.append(missCoordinates)
                    }
                }
            }
        }
        return Recommendation(availabilityType: availabilityType, missingTypes: missingTypes, existObjects: objects, coordinates: emptyCoordinates)
    }
}
