//
//  DepartmentResponse.swift
//  MosSportMap
//
//  Created by sergiusX on 15/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import Foundation

struct DepartmentResponse: CodableMappable {
    let departments: [Department]
}

struct Department: CodableMappable {
    let id: Int // АйДи организации | 219165
    let title: String // Название организации | Москомспорт
}

extension Department: Equatable, Hashable {

    static func == (lhs: Department, rhs: Department) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}
