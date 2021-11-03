//
//  Rating.swift
//  MosSportMap
//
//  Created by Sergey D on 03.11.2021.
//

import Foundation

class Rating {
    /// Район
    var population: Population!
    /// Место района по численности
    var placeByPopulation: Int = 0
    var placeByPopulationValue: Double = 0.0
    /// Место района по площади
    var placeBySquare: Int = 0
    var placeBySquareValue: Double = 0.0
    /// Место района по спортивным объектам
    var placebySportObjects: Int = 0
    var placebySportObjectsValue: Int = 0
    /// Место района по площади спортивных объектов
    var placeBySportSquare: Int = 0
    var placeBySportSquareValue: Double = 0.0
    /// Место района по видам спорта на одного
    var placeBySportTypes: Int = 0
    var placeBySportTypesValue: Int = 0
    /// Место района по площади спортивных районов на одного
    var placeBySquareForOne: Int = 0
    var placeBySquareForOneValue: Double = 0.0
    /// Место района по видам спорта на одного
    var placeBySportForOne: Int = 0
    var placeBySportForOneValue: Double = 0.0
    /// Место района по спортивным объектам на одного
    var placeByObjectForOne: Int = 0
    var placeByObjectForOneValue: Double = 0.0
}
