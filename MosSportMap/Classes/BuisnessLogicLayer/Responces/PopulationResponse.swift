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
    let area: String
    let population: Double
    let square: Double
}

extension Population: Equatable, Hashable {

    static func == (lhs: Population, rhs: Population) -> Bool {
        return lhs.area == rhs.area
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.area)
    }
}
//
//struct PopulationSquares: CodableMappable {
//    let area: String
//    let population: Double
//    let square: Double
//}
//
//extension PopulationSquares: Equatable, Hashable {
//
//    static func == (lhs: PopulationSquares, rhs: PopulationSquares) -> Bool {
//        return lhs.area == rhs.area
//    }
//
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(self.area)
//    }
//}
