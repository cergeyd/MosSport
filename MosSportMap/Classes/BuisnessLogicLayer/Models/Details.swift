//
//  Details.swift
//  MosSportMap
//
//  Created by Sergeyd on 19.10.2021.
//

import Foundation

struct DepartmentSection {
    let department: Department
    let sportObjects: [SportObject]
}

struct SportTypeSection {
    let type: SportType
    let sportObjects: [SportObject]
}

struct DetailSection {
    let title: String
    let details: [Detail]
}

struct Detail {
    let type: DetailType
    let title: String
    let place: String
    let subtitle: String
}
