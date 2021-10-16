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
}
