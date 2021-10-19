//
//  MenuSection.swift
//  MosSportMap
//
//  Created by Sergeyd on 19.10.2021.
//

import Foundation

struct MenuSection {
    let title: String
    let items: [MenuItem]
}

struct MenuItem {
    let title: String
    let subtitle: String
    let isDetailed: Bool
    let type: MenuType
}
