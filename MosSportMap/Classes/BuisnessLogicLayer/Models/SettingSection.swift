//
//  SettingSection.swift
//  MosSportMap
//
//  Created by Sergey D on 03.11.2021.
//

import Foundation

struct SettingSection {

    enum `Type` {
        case OSM
        case calculated
        case download
    }

    let header: String
    let type: `Type`
}
