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
    
    /// Место района по площади
    let placeBySquare: Int
    /// Место района по спортивным объектам
    let placebySportObjects: Int
    /// Место района по площади спортивных объектов
    let placeBySportSquare: Int
    /// Место района по спортивным видам
    let placeBySportTypes: Int
    /// Место района по площади спортивных районов на одного
    let placeBySquareForOne: Int
    /// Место района по видам спорта на одного
    let placeBySportForOne: Int
    /// Место района по спортивным объектам на одного
    let placeByObjectForOne: Int
    
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
