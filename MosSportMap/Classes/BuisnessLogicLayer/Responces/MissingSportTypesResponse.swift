//
//  MissingSportTypesResponse.swift
//  MosSportMap
//
//  Created by Sergey D on 06.11.2021.
//

import Foundation

struct MissingSportTypesResponse: CodableMappable {
    let population: Population
    let existingSports: [SportType]
    let missingSports: [SportType]
}
