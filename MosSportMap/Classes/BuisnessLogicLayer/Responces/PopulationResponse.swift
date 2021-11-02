//
//  PopulationResponse.swift
//  MosSportMap
//
//  Created by sergiusX on 15/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import Foundation

struct PopulationResponse: CodableMappable {
    let populations: [Population]
}

struct Population: CodableMappable {
    
    struct Rating: CodableMappable {
        /// Место района по численности
        let placeByPopulation: Int
        let placeByPopulationValue: Double
        /// Место района по площади
        let placeBySquare: Int
        let placeBySquareValue: Double
        /// Место района по спортивным объектам
        let placebySportObjects: Int
        let placebySportObjectsValue: Int
        /// Место района по площади спортивных объектов
        let placeBySportSquare: Int
        let placeBySportSquareValue: Double
        /// Место района по спортивным видам
        let placeBySportTypes: Int
        let placeBySportTypesValue: Int
        /// Место района по площади спортивных районов на одного
        let placeBySquareForOne: Int
        let placeBySquareForOneValue: Double
        /// Место района по видам спорта на одного
        let placeBySportForOne: Int
        let placeBySportForOneValue: Double
        /// Место района по спортивным объектам на одного
        let placeByObjectForOne: Int
        let placeByObjectForOneValue: Double
    }
    
    let area: String
    let population: Double
    let square: Double
    let latitude: Double
    let longitude: Double
    let rating: Rating
}

extension Population: Equatable, Hashable {

    static func == (lhs: Population, rhs: Population) -> Bool {
        return lhs.area == rhs.area
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.area)
    }
}
