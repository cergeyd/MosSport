//
//  CVSModule.swift
//  MosSportMap
//
//  Created by Sergey D on 05.11.2021.
//

import SwiftCSV

class CVSModule {

    /// "id Объекта;Объект;Адрес;id Ведомственной Организации;Ведомственная Организация;id Спортзоны;Спортзона;Тип спортзоны;Доступность;Доступность;Вид спорта;Широта (Latitude);Долгота (Longitude);;;;Площадь спортзоны"

    /// Парсим CVS
    static func parseCSV(filepath: URL) -> [SportObject] {
        do {
            let csv: CSV = try CSV(url: filepath, delimiter: ";", encoding: .utf8, loadColumns: true)
            var objects: [SportObject] = []
            /// Парсим в нашу модель. Вцелом тайой себе подход, но если начальная модель не меняется то норм.
            try csv.enumerateAsArray(startAt: 0, rowLimit: nil, { array in
                if (array.count == 17) {
                    /// Айди объекта
                    let id = array[0]
                    /// Объект
                    let title = array[1]
                    /// Адрес
                    let address = array[2]
                    /// id Ведомственной Организации
                    let departmentID = array[3]
                    /// Ведомственная Организация. Не нужен т.к. уже есть. TODO Если нет - нужно добавить новый
                    ///let departmentTitle = array[4]
                    /// id Спортзоны
                    let sportID = array[5]
                    /// Спортзона
                    let sportTitle = array[6]
                    /// Тип спортзоны. Не нужен т.к. уже есть. TODO Если нет - нужно добавить новый
                    let sportType = array[7]
                    /// Доступность
                    let availability = array[9]
                    /// Вид спорта
                    let sportView = array[10]
                    /// Широта
                    let latitude = array[11]
                    /// Долгота
                    let longitude = array[12]
                    /// Площадь
                    let square = array[16]

                    /// TODO. Нет департамена - создадим новый.

                    /// Данные
                    if let id = Int(id),
                        let departmentId = Int(departmentID),
                        let department = SharedManager.shared.department(for: departmentId),
                        let availability = SharedManager.shared.availabilityType(for: availability) {

                        /// Координаты
                        if let lati = Double(latitude), let long = Double(longitude) {
                            let coordinate = SportObject.Coordinate(latitude: lati, longitude: long)

                            /// Сам спорт
                            if let _sportID = Int(sportID), let _square = Double(square), let type = SharedManager.shared.sportType(for: sportView) {
                                let sport = SportObject.Sport.init(sportAreaID: _sportID, sportArea: sportTitle, sportAreaType: sportType, sportType: type, square: _square)
                                let object = SportObject(id: id, title: title, address: address, sport: [sport], department: department, availabilityType: availability, coordinate: coordinate)
                                objects.append(object)
                            }
                        }
                    }
                }
            })
            return objects
        } catch {
            return []
        }
    }

    // MARK: Private func
    private static func openCSV(filepath: URL) -> String! {
        do {
            let contents = try String(contentsOf: filepath)
            return contents
        } catch {
            print("File Read Error for file \(filepath)")
            return nil
        }
    }
}
