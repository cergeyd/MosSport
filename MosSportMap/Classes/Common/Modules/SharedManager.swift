//
//  SharedManager.swift
//  MosSportMap
//
//  Created by Sergeyd on 16.10.2021.
//

import GoogleMapsUtils

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
        let color = #colorLiteral(red: 1, green: 0.1709959209, blue: 0.02205365524, alpha: 1).withAlphaComponent(0.6)
        if let title = area, let population = SharedManager.shared.population(by: title) {
            let maxPop = Config.maxPopultaionValue
            let currentPop = Double(population.population)
            let percent = (currentPop / maxPop) * 100.0
            let lighter = color.darker(by: percent)
            return lighter!
        }
        return color.withAlphaComponent(0.1)
    }
    
    /// Отчёт
    func calculateSportSquare(for population: Population, polygon: GMSPolygon) -> SquareReport {
        var objects: [SportObject] = []
        var sports: [SportObject.Sport] = []
        var sportTypes: Set<SportType> = []
        var allSquare = 0.0
        for object in sportObjectResponse.objects {
            if (polygon.contains(coordinate: object.coorditate)) {
                objects.append(object)
                for sport in object.sport {
                    sports.append(sport)
                    sportTypes.insert(sport.sportType)
                    allSquare += sport.square ?? 0.0
                }
            }
        }
        let squareForOne = allSquare / population.population
        let sportForOne = Double(sports.count) / population.population
        let objectForOne = Double(objects.count) / population.population
        let sportTypeForOne = Double(sportTypes.count) / population.population
        let square = polygon.area()
        let sortedSportTypes = sportTypes.sorted(by: { $0.id < $1.id })

        return SquareReport(population: population, square: square, objects: objects, sports: sports, sportTypes: sortedSportTypes, allSquare: allSquare, squareForOne: squareForOne, sportForOne: sportForOne, objectForOne: objectForOne, sportTypeForOne: sportTypeForOne)
    }
}
