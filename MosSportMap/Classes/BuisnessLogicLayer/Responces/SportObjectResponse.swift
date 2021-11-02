//
//  SportObjectResponse.swift
//  MosSportMap
//
//  Created by sergiusX on 15/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import RxSwift
import CoreLocation

struct SportObjectResponse: CodableMappable {
    var objects: [SportObject]
}

struct SportObject: CodableMappable {

    enum AvailabilityType: String, Codable {
        case walking = "Шаговая доступность"
        case district = "Районное"
        case area = "Окружное"
        case city = "Городское"
    }

    struct Sport: CodableMappable {
        let sportAreaID: Int // АйДи спортзоны, у каждого вида спорта свой айди | 1014648
        let sportArea: String // Спортзона | бассейн плавательный 25-ти метровый крытый
        let sportAreaType: String // Тип спортзоны. Идентичен Спортзоне ? | бассейн плавательный 25-ти метровый крытый
        let sportType: SportType // Вид спорта | Плавание
        let square: Double // Площадь спортзоны | 150.0 
    }

    struct Coordinate: CodableMappable {
        let latitude: Double
        let longitude: Double
    }

    let id: Int // Не уникальный. Несколько объектов с разными видами спорта | 100002
    let title: String // Название объекта, идентичный | Спортивный комплекс «Полярная звезда»
    let address: String // Адрес, идентичный | проезд Шокальского, дом 45, корпус 3
    let sport: [Sport] // Информация о спорте
    let department: Department // Департамент
    let availabilityType: AvailabilityType // Доступность, рассчитана на посетителей в данном покрытии | Районное
    let coordinate: Coordinate

    var coorditate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.coordinate.latitude, longitude: self.coordinate.longitude)
    }
}
