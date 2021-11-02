//
//  SquareReport.swift
//  MosSportMap
//
//  Created by Sergeyd on 16.10.2021.
//

import Foundation

struct SquareReport {
    let population: Population
    /// Ведомства в районе
    let departments: [Department]
    /// Спортивные объекты для района
    let objects: [SportObject]
    /// Спорт для района
    let sports: [SportObject.Sport]
    /// Виды спорта для района
    let sportTypes: [SportType]
    /// Площадь всех спортивных объектов
    let allSquare: Double
    /// Площадь для одного человека
    let squareForOne: Double
    /// Спорт для одного человека
    let sportForOne: Double
    /// Спортивные объекты для одного человека
    let objectForOne: Double
    /// Типы спорта для одного человека
    let sportTypeForOne: Double
}
