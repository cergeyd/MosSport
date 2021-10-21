//
//  SharedManager.swift
//  MosSportMap
//
//  Created by Sergeyd on 16.10.2021.
//

import GoogleMapsUtils

let gSquareToKilometers = 1_000_000.0 /// Площадь вычесляется по границам. Крайне точно, но нам нужоны просто километры
let gCalculatePerPeoples = 100_000.0 /// на 100 000 человек на выбранной территории;
var lastSelectedAreaReport: SquareReport?

class SharedManager {

    struct Config {
        static let maxPopultaionValue = 30_387.21
    }

    static let shared = SharedManager()
    var allPolygons: [GMSPolygon] = []
    let geoCoder = CLGeocoder()

    /// Население по области
    func population(by area: String?) -> Population? {
        for population in populationResponse.populations {
            if (population.area.lowercased() == area?.lowercased()) {
                return population
            }
        }
        return nil
    }

    /// Область для населения
    func polygon(by population: Population) -> GMSPolygon? {
        for polygon in self.allPolygons {
            if let title = polygon.title {
                if (title.lowercased() == population.area.lowercased()) {
                    return polygon
                }
            }
        }
        return nil
    }

    /// Население по области
    func calculateColor(for area: String?) -> UIColor {
        let color = AppStyle.color(for: .coloured).withAlphaComponent(0.5)
        if let title = area, let population = SharedManager.shared.population(by: title) {
            let maxPop = Config.maxPopultaionValue
            let currentPop = Double(population.population)
            let percent = (currentPop / maxPop) * 100.0
            let lighter = color.darker(by: percent)
            return lighter!
        }
        return color.withAlphaComponent(0.1)
    }

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

    /// Адрес по координатам
    func coordinates(by population: Population, completion: @escaping (_ coordinates: CLLocationCoordinate2D?) -> Void) {
        self.geoCoder.geocodeAddressString("Москва, \(population.area)") { (placemarks, error) in
            guard let placemarks = placemarks, let location = placemarks.first?.location
                else {
                completion(nil)
                return
            }
            completion(location.coordinate)
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

    func missingSportTypes(objects: [SportObject]) -> [SportType] {
        var missing: [SportType] = []
        let sports = objects.flatMap({ $0.sport })
        let exist = sports.compactMap({ $0.sportType })

        for type in sportTypes.types {
            if (!exist.contains(where: { detail in
                return detail == type
            })) {
                missing.append(type)
            }
        }
        return missing
    }

    /// Отчёт
    func calculateSportSquare(for population: Population, polygon: GMSPolygon? = nil, path: GMSMutablePath? = nil) -> SquareReport {
        var objects: [SportObject] = []
        var sports: [SportObject.Sport] = []
        var sportTypes: Set<SportType> = []
        var departments: Set<Department> = []
        var allSquare = 0.0

        for object in sportObjectResponse.objects {
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
                    allSquare += sport.square ?? 0.0
                }
            }
        }
        /// Площадь спортивных объектов на одного
        let squareForOne = allSquare / gCalculatePerPeoples
        let sportForOne = Double(sports.count) / gCalculatePerPeoples
        let objectForOne = Double(objects.count) / gCalculatePerPeoples
        let sportTypeForOne = Double(sportTypes.count) / gCalculatePerPeoples
        let sortedSportTypes = sportTypes.sorted(by: { $0.id < $1.id })

        let report = SquareReport(
            population: population,
            departments: departments.sorted(by: { $0.id < $1.id }),
            placeBySquare: 0,
            placebySportObjects: 0,
            placeBySportSquare: 0,
            placeBySportTypes: 0,
            placeBySquareForOne: 0,
            placeBySportForOne: 0,
            placeByObjectForOne: 0,
            objects: objects,
            sports: sports,
            sportTypes: sortedSportTypes,
            allSquare: allSquare,
            squareForOne: squareForOne,
            sportForOne: sportForOne,
            objectForOne: objectForOne,
            sportTypeForOne: sportTypeForOne)
        lastSelectedAreaReport = report
        return report
    }

    func findSportObjectsAround(object: SportObject) -> SportObjectsAround {
        var sportObjectsArea: [SportObject] = []
        var sportObjectsDistrict: [SportObject] = []
        var sportObjectsWalking: [SportObject] = []
        var sportObjectsCity: [SportObject] = []

        let currentLocation = CLLocation(latitude: object.coordinate.latitude, longitude: object.coordinate.longitude)
        for object in sportObjectResponse.objects {
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
        for object in sportObjectResponse.objects {
            if (object.sport.contains(where: { $0.sportType == type })) {
                objects.append(object)
            }
        }
        return (type, objects)
    }

    func objects(for department: Department) -> [SportObject] {
        var objects: [SportObject] = []
        for object in sportObjectResponse.objects {
            if (object.department == department) {
                objects.append(object)
            }
        }
        return objects
    }

    func objects(for polygon: GMSPolygon, with availability: SportObject.AvailabilityType) -> [SportObject] {
        var objects: [SportObject] = []
        for object in sportObjectResponse.objects {
            if (polygon.contains(coordinate: object.coorditate) && object.availabilityType == availability) {
                objects.append(object)
            }
        }
        return objects
    }

//    private func placeNumber(for population: Population, type: DetailType, allPolygons: [GMSPolygon]) -> Int {
//        switch type {
//        case .region:
//            break
//        case .population:
//            for (ind, _population) in populationResponse.populations.enumerated() {
//                if (_population == population) {
//                    return ind + 1
//                }
//            }
//        case .square:
//            let sortBySqare = populationResponse.populations.sorted(by: { $0.square > $1.square })
//            for (ind, _population) in sortBySqare.enumerated() {
//                if (_population == population) {
//                    return ind + 1
//                }
//            }
//        case .sportObjects:
//            return 1
//            var objectsDict: [String: Int] = [:]
//            for object in sportObjectResponse.objects {
//                for polygon in allPolygons {
//                    if (polygon.contains(coordinate: object.coorditate)) {
//                        if let title = polygon.title {
//                            if let count = objectsDict[title] {
//                                objectsDict[title] = count + 1
//                            } else {
//                                objectsDict[title] = 1
//                            }
//                        }
//                    }
//                }
//            }
//            var areaWithSports: [AreaWithSports] = []
//            for key in objectsDict.keys {
//                let count = objectsDict[key] ?? 0
//                areaWithSports.append(AreaWithSports(area: key, count: count))
//            }
//            areaWithSports.sort(by: { $0.count > $1.count })
//            for (ind, area) in areaWithSports.enumerated() {
//                if (population.area == area.area) {
//                    return ind + 1
//                }
//            }
//        case .sportSquare:
//            var objectsDict: [String: Int] = [:]
//            for object in sportObjectResponse.objects {
//                for sport in object.sport {
//                    for polygon in allPolygons {
//                        if (polygon.contains(coordinate: object.coorditate)) {
//                            if let title = polygon.title {
//                                if let square = objectsDict[title] {
//                                    let sportSquare = sport.square ?? 10.0
//                                    objectsDict[title] = square + Int(sportSquare)
//                                } else {
//                                    objectsDict[title] = 1
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//            var areaWithSports: [AreaWithSports] = []
//            for key in objectsDict.keys {
//                let count = objectsDict[key] ?? 0
//                areaWithSports.append(AreaWithSports(area: key, count: count))
//            }
//            areaWithSports.sort(by: { $0.count > $1.count })
//            for (ind, area) in areaWithSports.enumerated() {
//                if (population.area == area.area) {
//                    return ind + 1
//                }
//            }
//        }
//        return 0
//    }
}

struct AreaWithSports {
    let area: String
    let count: Int
}
