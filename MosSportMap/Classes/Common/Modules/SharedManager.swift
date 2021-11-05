//
//  SharedManager.swift
//  MosSportMap
//
//  Created by Sergeyd on 16.10.2021.
//

import GoogleMapsUtils

/// Environments
var googleAPIkey: String {
    return Bundle.main.object(forInfoDictionaryKey: "GoogleAPIkey") as! String
}

var hostUrl: String {
    return Bundle.main.object(forInfoDictionaryKey: "HostURL") as! String
}

let gSquareToKilometers = 1_000_000.0 /// Площадь вычесляется по границам. Крайне точно, но нам нужоны просто килОметры
let gCalculatePerPeoples = 100_000.0 /// На 100 000 человек на выбранной территории;
var currentCalculatePerPeoples = 0/// Установленное значение из настроек
var lastSelectedAreaReport: SquareReport? /// Запоминаем, выбранную территорию

class SharedManager {

    struct Config {
        static let maxPopultaionValue = 30_387.21
    }

    static let shared = SharedManager()

    /// Все полигоны Москвы
    var allPolygons: [GMSPolygon] = []
    let geoCoder = CLGeocoder()

    //MARK: Func
    /// Население по области
    func population(by area: String?) -> Population? {
        for population in gPopulationResponse.populations { if (population.area.lowercased() == area?.lowercased()) { return population } }
        return nil
    }

    /// Область для населения
    func polygon(by population: Population) -> GMSPolygon? {
        for polygon in self.allPolygons { if let title = polygon.title { if (title.lowercased() == population.area.lowercased()) { return polygon } } }
        return nil
    }

    /// Цвет, в зависимости от население по региону
    func calculateColor(for area: String?) -> UIColor {
        let color = AppStyle.color(for: .coloured)
        if let title = area, let population = SharedManager.shared.population(by: title) {
            let maxPop = Config.maxPopultaionValue
            let currentPop = Double(population.population)
            let percent = (currentPop / maxPop)
            let lighter = color.darker(by: percent * 100.0)?.withAlphaComponent(max(percent, 0.5)) ?? color.withAlphaComponent(0.1)
            return lighter
        }
        return color.withAlphaComponent(0.1)
    }

    /// Метры для доступности
    func meters(for availability: SportObject.AvailabilityType) -> Double {
        switch availability {
        case .walking:
            return 500.0
        case .district:
            return 1000.0
        case .area:
            return 3000.0
        case .city:
            return 5000.0
        }
    }

    /// Название доступности
    func title(for availabilityInd: Int) -> String {
        switch availabilityInd {
        case 0:
            return "Шаговая доступность"
        case 1:
            return "Районное"
        case 2:
            return "Окружное"
        default:
            return "Городское"
        }
    }

    /// Координаты по адресу
    func address(for coordinates: CLLocationCoordinate2D, completion: @escaping (_ address: Address?) -> Void) {
        let ceo = CLGeocoder()
        ceo.reverseGeocodeLocation(CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude), completionHandler:
            { (placemarks, error) in
                if (error != nil) {
                    completion(nil)
                    print("reverse geodcode fail: \(error!.localizedDescription)")
                }
                if let placemarks = placemarks {
                    if (placemarks.count) > 0 {
                        let pm = placemarks[0]
                        let city = pm.locality
                        let county = pm.country
                        let code = pm.isoCountryCode
                        let thoroughfare = pm.thoroughfare ?? ""
                        let subThoroughfare = pm.subThoroughfare ?? ""
                        var street = thoroughfare + " " + subThoroughfare
                        if (street == " ") {
                            street = "Улица не определена"
                        }
                        completion(Address(city: city, street: street, country: county, countyCode: code))
                    } else {
                        completion(nil)
                    }
                } else {
                    completion(nil)
                }
            })
    }

    /// Каких видов игр нет среди представленных
    func missingSportTypes(objects: [SportObject]) -> [SportType] {
        var missing: [SportType] = []
        let sports = objects.flatMap({ $0.sport })
        let exist = sports.compactMap({ $0.sportType })

        for type in gSportTypes.types {
            if (!exist.contains(where: { detail in
                return detail == type
            })) {
                missing.append(type)
            }
        }
        return missing
    }

    /// Отчёт
    func calculateReport(for population: Population, polygon: GMSPolygon? = nil, path: GMSMutablePath? = nil) -> SquareReport {
        var objects: [SportObject] = []
        var sports: [SportObject.Sport] = []
        var sportTypes: Set<SportType> = []
        var departments: Set<Department> = []
        var allSquare = 0.0

        for object in gSportObjectResponse.objects {
            var isContains = false
            if let polygon = polygon {
                isContains = polygon.contains(coordinate: object.coorditate)
            } else if let path = path {
                isContains = path.contains(coordinate: object.coorditate, geodesic: false)
            }
            if (isContains) {
                objects.append(object)
                departments.insert(object.department)
                for sport in object.sport {
                    sports.append(sport)
                    sportTypes.insert(sport.sportType)
                    allSquare += sport.square
                }
            }
        }
        allSquare /= 1000 /// В метры
        ///
        /// Площадь спортивных объектов на одного
        ///
        var perPeople = population.population
        if (currentCalculatePerPeoples != 0) { perPeople = Double(currentCalculatePerPeoples) }
        let squareForOne = allSquare / perPeople
        let sportForOne = Double(sports.count) / perPeople
        let objectForOne = Double(objects.count) / perPeople
        let sportTypeForOne = Double(sportTypes.count) / perPeople

        let report = SquareReport(
            population: population,
            departments: departments.sorted(by: { $0.id < $1.id }),
            objects: objects,
            sports: sports,
            sportTypes: sportTypes.sorted(by: { $0.id < $1.id }),
            allSquare: allSquare,
            squareForOne: squareForOne,
            sportForOne: sportForOne,
            objectForOne: objectForOne,
            sportTypeForOne: sportTypeForOne)
        lastSelectedAreaReport = report
        return report
    }

    /// Спортивные объекты в зависимости от доступности
    func findSportObjectsAround(object: SportObject) -> SportObjectsAround {
        var sportObjectsArea: [SportObject] = []
        var sportObjectsDistrict: [SportObject] = []
        var sportObjectsWalking: [SportObject] = []
        var sportObjectsCity: [SportObject] = []

        let currentLocation = CLLocation(latitude: object.coordinate.latitude, longitude: object.coordinate.longitude)
        for object in gSportObjectResponse.objects {
            let location = CLLocation(latitude: object.coordinate.latitude, longitude: object.coordinate.longitude)
            let distance = currentLocation.distance(from: location)
            switch distance {
            case 1..<501:
                sportObjectsWalking.append(object)
            case 500..<1001:
                sportObjectsDistrict.append(object)
            case 1000..<3001:
                sportObjectsArea.append(object)
            case 3000..<5001:
                sportObjectsCity.append(object)
            default:
                break
            }
        }
        let around = SportObjectsAround(sportObjectsArea: sportObjectsArea, sportObjectsDistrict: sportObjectsDistrict, sportObjectsWalking: sportObjectsWalking, sportObjectsCity: sportObjectsCity)
        return around
    }

    func findSportObjects(by type: String) -> (type: SportType, objects: [SportObject]) {
        let type = SportType(id: 0, title: type)
        var objects: [SportObject] = []
        for object in gSportObjectResponse.objects {
            if (object.sport.contains(where: { $0.sportType == type })) {
                objects.append(object)
            }
        }
        return (type, objects)
    }

    func objects(for department: Department) -> [SportObject] {
        var objects: [SportObject] = []
        for object in gSportObjectResponse.objects {
            if (object.department == department) {
                objects.append(object)
            }
        }
        return objects
    }

    func objects(for polygon: GMSPolygon, with availability: SportObject.AvailabilityType) -> [SportObject] {
        var objects: [SportObject] = []
        for object in gSportObjectResponse.objects {
            if (polygon.contains(coordinate: object.coorditate) && object.availabilityType == availability) {
                objects.append(object)
            }
        }
        return objects
    }

    /// Получаем корректные промежутки заданного района
    func getRectangle(inside polygon: GMSPolygon) -> Rectangle {
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

    /// Дополнительные спортвные объекты. Обновим
    func updateSportObjectsList(isOSMObjects: Bool) {
        //var setSportObjects: Set<SportObject> = []
        if (isOSMObjects) {
            gSportObjectResponse.objects.append(contentsOf: gSportOSMObjectResponse.objects)
        } else {
            gSportObjectResponse = gSportMosSportObjectResponse
//            for object in gSportObjectResponse.objects {
//                if (!gSportOSMObjectResponse.objects.contains(object)) {
//                    setSportObjects.insert(object)
//                }
//            }
//            gSportOSMObjectResponse.objects = setSportObjects.sorted(by: { $0.id < $1.id })
        }
        NotificationCenter.default.post(name: NSNotification.Name.updateSportObjectsList, object: nil)
    }
}
