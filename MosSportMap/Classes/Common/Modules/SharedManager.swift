//
//  SharedManager.swift
//  MosSportMap
//
//  Created by Sergeyd on 16.10.2021.
//

import GoogleMapsUtils

let gSquareToKilometers = 1_000_000.0 /// Площадь вычесляется по границам. Крайне точно, но нам нужоны просто километры

class SharedManager {

    struct Config {
        static let maxPopultaionValue = 30_387.21
    }

    static let shared = SharedManager()

    /// Население по области
    func population(by area: String) -> Population? {
        for population in populationResponse.populations {
            if (population.area.lowercased() == area.lowercased()) {
                return population
            }
        }
        return nil
    }

    /// Население по области
    func calculateColor(for area: String?) -> UIColor {
        let color = AppStyle.color(for: .coloured).withAlphaComponent(0.4)
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

    /// Отчёт
    func calculateSportSquare(for population: Population, polygon: GMSPolygon, allPolygons: [GMSPolygon]) -> SquareReport {
        var objects: [SportObject] = []
        var sports: [SportObject.Sport] = []
        var sportTypes: Set<SportType> = []
        var departments: Set<Department> = []
        var allSquare = 0.0
        for object in sportObjectResponse.objects {
            if (polygon.contains(coordinate: object.coorditate)) {
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
        let squareForOne = (allSquare / 100) / population.population
        let sportForOne = Double(sports.count) / population.population
        let objectForOne = Double(objects.count) / population.population
        let sportTypeForOne = Double(sportTypes.count) / population.population
        let sortedSportTypes = sportTypes.sorted(by: { $0.id < $1.id })

//        let placeBySquare = self.placeNumber(for: population, type: .population, allPolygons: allPolygons)
//        let placebySportObjects = self.placeNumber(for: population, type: .sportObjects, allPolygons: allPolygons)
//        let placeBySportSquare = self.placeNumber(for: population, type: .sportSquare, allPolygons: allPolygons)

        return SquareReport(
            population: population, departments: departments.sorted(by: { $0.id < $1.id }),
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
    
    func objects(for department: Department) -> [SportObject] {
        var objects: [SportObject] = []
        for object in sportObjectResponse.objects {
            if (object.department == department) {
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
