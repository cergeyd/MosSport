//
//  RecommendationRecommendationViewController.swift
//  MosSportMap
//
//  Created by sergiusX on 21/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import GoogleMapsUtils

struct Rectangle {
    let topLeft: CLLocationCoordinate2D
    let bottomRight: CLLocationCoordinate2D
}

struct Recommendation {
    let availabilityType: SportObject.AvailabilityType
    let missingTypes: [SportType]
    let coordinates: [CLLocationCoordinate2D]
}

enum RecommendationType {
    case area
    case availability(area: Population, polygon: GMSPolygon)
    case objects(area: Population, availability: SportObject.AvailabilityType, recommendation: Recommendation)
}

protocol RecommendationDelegate: AnyObject {
    func didSelect(calculated type: CalculateAreaType?)
    func didCalculate(recommendation: Recommendation)
    func didSelect(population: Population, polygon: GMSPolygon)
}

class RecommendationViewController: TableViewController {

    var output: RecommendationViewOutput!
    var type: MenuType!
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
        self.navigationItem.searchController = self.searchController
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
            for population in populationResponse.populations {
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
            self.title = "Рекоммендация"
            self.delegate?.didCalculate(recommendation: recommendations)
            /// Регион
            let populationValue = Int(area.population)
            let square = area.square / gSquareToKilometers
            let area = Detail(type: .filter, title: area.area, place: populationValue.peoples() + "/км²", subtitle: "Площадь района: \(square.formattedWithSeparator + " км²")")

            /// Доступность
            let range = SharedManager.shared.meters(for: availability)
            let availability = Detail(type: .filter, title: availability.rawValue, place: "", subtitle: "В радиусе \(range) м.")

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
        if (self.isSearchActive) {
            return self.filterDetails[indexPath.row]
        }
        return self.sections[indexPath.section].details[indexPath.row]
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        if (self.isSearchActive) {
            return 1
        }
        return self.sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.isSearchActive) {
            return self.filterDetails.count
        }
        return self.sections[section].details.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (self.isSearchActive) {
            return "Результаты:"
        }
        return self.sections[section].title
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let detailCell = tableView.dequeueReusableCell(withIdentifier: DetailCell.identifier) as! DetailCell
        let item = self.detail(at: indexPath)
        detailCell.accessoryType = .disclosureIndicator
        detailCell.configure(with: item, indexPath: indexPath)
        return detailCell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
        switch self.recommendationType {
        case .area:
            let area = self.detail(at: indexPath)
            if let population = SharedManager.shared.population(by: area.title), let polygon = SharedManager.shared.polygon(by: population) {
                self.delegate?.didSelect(population: population, polygon: polygon)
                self.output.didSelect(recommendationType: .availability(area: population, polygon: polygon))
            }
        case .availability(area: let area, polygon: let polygon):
            let availability = self.detail(at: indexPath)
            if let type = SportObject.AvailabilityType.init(rawValue: availability.title) {
                let recommendation = self.calculateRecommendation(in: polygon, availabilityType: type)
                self.output.didSelect(recommendationType: .objects(area: area, availability: type, recommendation: recommendation))
            }
        case .objects:
            break
        }
    }

    /// Получаем корректные промежутки заданного района
    private func getRectangle(inside polygon: GMSPolygon) -> Rectangle {
        var minLeft: Double = 90.0
        var topLeft: Double = 0.0
        var maxRight: Double = 0.0
        var bottomRight: Double = 90.0
        if let allCoordinates = polygon.path?.allCoordinates {
            for coordinate in allCoordinates {
                let latitude = coordinate.latitude
                let longitude = coordinate.longitude
                if (longitude < minLeft) { minLeft = longitude }
                if (latitude > topLeft) { topLeft = latitude }
                if (longitude > maxRight) { maxRight = longitude }
                if (latitude < bottomRight) { bottomRight = latitude }
            }
        }
        let topLeftCoord = CLLocationCoordinate2D(latitude: topLeft, longitude: minLeft)
        let bottomRightCoord = CLLocationCoordinate2D(latitude: bottomRight, longitude: maxRight)
        return Rectangle(topLeft: topLeftCoord, bottomRight: bottomRightCoord)
    }

    private func calculateRecommendation(in polygon: GMSPolygon, availabilityType: SportObject.AvailabilityType) -> Recommendation {
        /// Границы региона
        let rectangle = self.getRectangle(inside: polygon)
        /// Объекты, которые уже есть в регионе
        let objects = SharedManager.shared.objects(for: polygon, with: availabilityType)
        /// Виды спорта, которых не хватает
        let missingTypes = SharedManager.shared.missingSportTypes(objects: objects)
        /// Координаты, где можно разместить объект
        var emptyCoordinates: [CLLocationCoordinate2D] = []
        let range = SharedManager.shared.meters(for: availabilityType)

        for i in stride(from: rectangle.topLeft.longitude, to: rectangle.bottomRight.longitude, by: 0.003) {
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
                        if (minDistance > range) {
                            emptyCoordinates.append(missCoordinates)
                        }
                    }
                }
            }
        }
        return Recommendation(availabilityType: availabilityType, missingTypes: missingTypes, coordinates: emptyCoordinates)
    }
}
