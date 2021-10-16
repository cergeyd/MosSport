//
//  SportTypeResponse.swift
//  MosSportMap
//
//  Created by sergiusX on 15/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import Foundation

struct SportTypeResponse: CodableMappable {
    let types: [SportType]
}

struct SportType: CodableMappable {
    let id: Int
    let title: String
}

extension SportType: Equatable, Hashable {

    static func == (lhs: SportType, rhs: SportType) -> Bool {
        return lhs.title == rhs.title
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.title)
    }
}
