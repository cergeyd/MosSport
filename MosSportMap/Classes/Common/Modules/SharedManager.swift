//
//  SharedManager.swift
//  MosSportMap
//
//  Created by Sergeyd on 16.10.2021.
//

import GoogleMapsUtils

/// Environments
var googleAPIkey: String {
    return Bundle.main.object(forInfoDictionaryKey: "GoogleAPIkey") as! String
}

var hostUrl: String {
    return Bundle.main.object(forInfoDictionaryKey: "HostURL") as! String
}

let gSquareToKilometers = 1_000_000.0 /// Площадь вычесляется по границам. Крайне точно, но нам нужоны просто килОметры
let gCalculatePerPeoples = 100_000.0 /// На 100 000 человек на выбранной территории;
var currentCalculatePerPeoples = 0/// Установленное значение из настроек
var lastSelectedAreaReport: SquareReport? /// Запоминаем, выбранную территорию

class SharedManager {

    struct Config {
        static let maxPopultaionValue = 30_387.21
        static let kNewObjects = "newObjects"
    }

    static let shared = SharedManager()

    /// Все полигоны Москвы
    var allPolygons: [GMSPolygon] = []
    let geoCoder = CLGeocoder()

    // MARK: Func
    /// Население по области
    func population(by area: String?) -> Population? {
        for population in gPopulationResponse.populations { if (population.area.lowercased() == area?.lowercased()) { return population } }
        return nil
    }

    /// Область для населения
    func polygon(by population: Population) -> GMSPolygon? {
        for polygon in self.allPolygons { if let title = polygon.title { if (title.lowercased() == population.area.lowercased()) { return polygon } } }
        return nil
    }

    /// Цвет, в зависимости от население по региону
    func calculateColor(for area: String?) -> UIColor {
        let color = AppStyle.color(for: .coloured)
        if let title = area, let population = SharedManager.shared.population(by: title) {
            let maxPop = Config.maxPopultaionValue
            let currentPop = Double(population.population)
            let percent = (currentPop / maxPop)
            let lighter = color.darker(by: percent * 100.0)?.withAlphaComponent(max(percent, 0.5)) ?? color.withAlphaComponent(0.1)
            return lighter
        }
        return color.withAlphaComponent(0.1)
    }

    /// Метры для доступности
    func meters(for availability: SportObject.AvailabilityType) -> Double {
        switch availability {
        case .walking:
            return 500.0
        case .district:
            return 1000.0
        case .area:
            return 3000.0
        case .city:
            return 5000.0
        }
    }

    /// Доступность
    func availabilityType(for title: String) -> SportObject.AvailabilityType? {
        return SportObject.AvailabilityType.init(rawValue: title)
    }

    /// Вип спорта
    func sportType(for ID: String) -> SportType? {
        for type in gSportTypes.types {
            if (type.title == ID) {
                return type
            }
        }
        return nil
    }

    /// Название доступности
    func title(for availabilityInd: Int) -> String {
        switch availabilityInd {
        case 0:
            return "Шаговая доступность"
        case 1:
            return "Районное"
        case 2:
            return "Окружное"
        default:
            return "Городское"
        }
    }

    /// Координаты по адресу
    func address(for coordinates: CLLocationCoordinate2D, completion: @escaping (_ address: Address?) -> Void) {
        let ceo = CLGeocoder()
        ceo.reverseGeocodeLocation(CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude), completionHandler:
            { (placemarks, error) in
                if (error != nil) {
                    completion(nil)
                    print("reverse geodcode fail: \(error!.localizedDescription)")
                }
                if let placemarks = placemarks {
                    if (placemarks.count) > 0 {
                        let pm = placemarks[0]
                        let city = pm.locality
                        let county = pm.country
                        let code = pm.isoCountryCode
                        let thoroughfare = pm.thoroughfare ?? ""
                        let subThoroughfare = pm.subThoroughfare ?? ""
                        var street = thoroughfare + " " + subThoroughfare
                        if (street == " ") {
                            street = "Улица не определена"
                        }
                        completion(Address(city: city, street: street, country: county, countyCode: code))
                    } else {
                        completion(nil)
                    }
                } else {
                    completion(nil)
                }
            })
    }

    /// Каких видов игр нет среди представленных
    func missingSportTypes(objects: [SportObject]) -> [SportType] {
        var missing: [SportType] = []
        let sports = objects.flatMap({ $0.sport })
        let exist = sports.compactMap({ $0.sportType })

        for type in gSportTypes.types {
            if (!exist.contains(where: { detail in
                return detail == type
            })) {
                missing.append(type)
            }
        }
        return missing
    }

    /// Отчёт
    func calculateReport(for population: Population, polygon: GMSPolygon? = nil, path: GMSMutablePath? = nil) -> SquareReport {
        var objects: [SportObject] = []
        var sports: [SportObject.Sport] = []
        var sportTypes: Set<SportType> = []
        var departments: Set<Department> = []
        var allSquare = 0.0

        for object in gSportObjectResponse.objects {
            var isContains = false
            if let polygon = polygon {
                isContains = polygon.contains(coordinate: object.coorditate)
            } else if let path = path {
                isContains = path.contains(coordinate: object.coorditate, geodesic: false)
            }
            if (isContains) {
                objects.append(object)
                departments.insert(object.department)
                for sport in object.sport {
                    sports.append(sport)
                    sportTypes.insert(sport.sportType)
                    allSquare += sport.square
                }
            }
        }
        allSquare /= 1000 /// В метры
        ///
        /// Площадь спортивных объектов на одного
        ///
        var perPeople = population.population
        if (currentCalculatePerPeoples != 0) { perPeople = Double(currentCalculatePerPeoples) }
        let squareForOne = allSquare / perPeople
        let sportForOne = Double(sports.count) / perPeople
        let objectForOne = Double(objects.count) / perPeople
        let sportTypeForOne = Double(sportTypes.count) / perPeople

        let report = SquareReport(
            population: population,
            departments: departments.sorted(by: { $0.id < $1.id }),
            objects: objects,
            sports: sports,
            sportTypes: sportTypes.sorted(by: { $0.id < $1.id }),
            allSquare: allSquare,
            squareForOne: squareForOne,
            sportForOne: sportForOne,
            objectForOne: objectForOne,
            sportTypeForOne: sportTypeForOne)
        lastSelectedAreaReport = report
        return report
    }

    /// Спортивные объекты в зависимости от доступности
    func findSportObjectsAround(object: SportObject) -> SportObjectsAround {
        var sportObjectsArea: [SportObject] = []
        var sportObjectsDistrict: [SportObject] = []
        var sportObjectsWalking: [SportObject] = []
        var sportObjectsCity: [SportObject] = []

        let currentLocation = CLLocation(latitude: object.coordinate.latitude, longitude: object.coordinate.longitude)
        for object in gSportObjectResponse.objects {
            let location = CLLocation(latitude: object.coordinate.latitude, longitude: object.coordinate.longitude)
            let distance = currentLocation.distance(from: location)
            switch distance {
            case 5..<501:
                sportObjectsWalking.append(object)
            case 500..<1001:
                sportObjectsDistrict.append(object)
            case 1000..<3001:
                sportObjectsArea.append(object)
            case 3000..<5001:
                sportObjectsCity.append(object)
            default:
                break
            }
        }
        let around = SportObjectsAround(sportObjectsArea: sportObjectsArea, sportObjectsDistrict: sportObjectsDistrict, sportObjectsWalking: sportObjectsWalking, sportObjectsCity: sportObjectsCity)
        return around
    }

    func findSportObjects(by type: String) -> (type: SportType, objects: [SportObject]) {
        let type = SportType(id: 0, title: type)
        var objects: [SportObject] = []
        for object in gSportObjectResponse.objects {
            if (object.sport.contains(where: { $0.sportType == type })) {
                objects.append(object)
            }
        }
        return (type, objects)
    }

    func objects(for department: Department) -> [SportObject] {
        var objects: [SportObject] = []
        for object in gSportObjectResponse.objects {
            if (object.department == department) {
                objects.append(object)
            }
        }
        return objects
    }

    func department(for id: Int) -> Department? {
        for object in gSportObjectResponse.objects {
            if (object.department.id == id) {
                return object.department
            }
        }
        return nil
    }

    func objects(for polygon: GMSPolygon, with availability: SportObject.AvailabilityType) -> [SportObject] {
        var objects: [SportObject] = []
        for object in gSportObjectResponse.objects {
            if (polygon.contains(coordinate: object.coorditate) && object.availabilityType == availability) {
                objects.append(object)
            }
        }
        return objects
    }

    /// Районы, в которых нет данного вида спорта
    func emptyPopulations(sportType: SportType) -> [Population] {
        var missings: [Population] = []
        for missing in gMissingSportTypesResponse {
            if (missing.missingSports.contains(sportType)) {
                missings.append(missing.population)
                continue
            }
        }
        return missings
    }

    /// Районы, в которых есть данный вид спорта
    func existPopulations(sportType: SportType) -> [Population] {
        var exist: [Population] = []
        for missing in gMissingSportTypesResponse {
            if (missing.existingSports.contains(sportType)) {
                exist.append(missing.population)
                continue
            }
        }
        return exist
    }

    /// Получаем корректные промежутки заданного района
    func getRectangle(inside polygon: GMSPolygon) -> Rectangle {
        // TODO: allCoordinates у Path пропал куда то
        return Rectangle(topLeft: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), bottomRight: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0))
//        var minLeft: Double = 90.0
//        var topLeft: Double = 0.0
//        var maxRight: Double = 0.0
//        var bottomRight: Double = 90.0
//        if let allCoordinates = polygon.path?.allCoordinates {
//            for coordinate in allCoordinates {
//                let latitude = coordinate.latitude
//                let longitude = coordinate.longitude
//                if (longitude < minLeft) { minLeft = longitude }
//                if (latitude > topLeft) { topLeft = latitude }
//                if (longitude > maxRight) { maxRight = longitude }
//                if (latitude < bottomRight) { bottomRight = latitude }
//            }
//        }
//        let topLeftCoord = CLLocationCoordinate2D(latitude: topLeft, longitude: minLeft)
//        let bottomRightCoord = CLLocationCoordinate2D(latitude: bottomRight, longitude: maxRight)
//        return Rectangle(topLeft: topLeftCoord, bottomRight: bottomRightCoord)
    }

    /// Дополнительные спортвные объекты. Обновим
    func updateSportObjectsList(isOSMObjects: Bool) {
        //var setSportObjects: Set<SportObject> = []
        if (isOSMObjects) {
            gSportObjectResponse.objects.append(contentsOf: gSportOSMObjectResponse.objects)
        } else {
            gSportObjectResponse = gSportMosSportObjectResponse
//            for object in gSportObjectResponse.objects {
//                if (!gSportOSMObjectResponse.objects.contains(object)) {
//                    setSportObjects.insert(object)
//                }
//            }
//            gSportOSMObjectResponse.objects = setSportObjects.sorted(by: { $0.id < $1.id })
        }
        NotificationCenter.default.post(name: NSNotification.Name.updateSportObjectsList, object: nil)
    }

    /// Объединим все объекты с одинаковыми играми в один объект
    func fromMultipleSportToSingle(objects: [SportObject]) -> [SportObject] {
        var sportObjects: [SportObject] = []
        var dict: [SportObject: [SportObject.Sport]] = [:]

        /// Идём по всем объектам и запоминаем игры
        for object in objects {
            if var sports = dict[object] {
                sports.append(contentsOf: object.sport)
                dict[object] = sports
            } else {
                dict[object] = object.sport
            }
        }

        let objectKeys = dict.keys
        for var object in objectKeys {
            let sports = dict[object]
            object.sport = sports ?? []
            /// Если с таким айди ещё нет
//            if (!gSportObjectResponse.objects.contains(where: { existObject in
//                return existObject.id == object.id
//            })) {
            sportObjects.append(object)
            //  }
        }

        let newObjects = self.getNewObjects()?.objects ?? []
        let newResponse = SportObjectResponse(objects: sportObjects + newObjects)
        self.save(object: newResponse, filename: Config.kNewObjects + ".json")
        return sportObjects
    }

    /// Рекомендация
    func calculateRecommendation(in polygon: GMSPolygon, availabilityType: SportObject.AvailabilityType, sportType: SportType? = nil) -> Recommendation {
        /// Границы региона
        let rectangle = SharedManager.shared.getRectangle(inside: polygon)
        /// Объекты, которые уже есть в регионе
        var objects = SharedManager.shared.objects(for: polygon, with: availabilityType)
        /// Виды спорта, которых не хватает
        let missingTypes = SharedManager.shared.missingSportTypes(objects: objects)
        /// Координаты, где можно разместить объект
        var emptyCoordinates: [CLLocationCoordinate2D] = []
        let range = SharedManager.shared.meters(for: availabilityType)

        /// Если нужна конкретная игра
        if let sportType = sportType {
            objects = objects.filter { object in
                return object.sport.contains(where: { sport in
                    return sport.sportType == sportType
                })
            }
        }

        let by = 0.003//sportType == nil ? 0.003 : 0.003
        let by1 = 0.003//sportType == nil ? 0.002 : 0.002

        for i in stride(from: rectangle.topLeft.longitude, to: rectangle.bottomRight.longitude, by: by) {
            for j in stride(from: rectangle.bottomRight.latitude, to: rectangle.topLeft.latitude, by: by1) {
                let missCoordinates = CLLocationCoordinate2D(latitude: j, longitude: i)
                if (polygon.contains(coordinate: missCoordinates)) {
                    var minDistance = 5000.0

                    for object in objects {
                        let existLocation = CLLocation(latitude: object.coordinate.latitude, longitude: object.coordinate.longitude)
                        let missLocation = CLLocation(latitude: missCoordinates.latitude, longitude: missCoordinates.longitude)

                        let distance = existLocation.distance(from: missLocation)
                        if (distance < minDistance) {
                            minDistance = distance
                        }
                    }
                    if (minDistance > range) { /// Сто метров offset
                        emptyCoordinates.append(missCoordinates)
                    }
                }
            }
        }
        return Recommendation(availabilityType: availabilityType, missingTypes: missingTypes, existObjects: objects, coordinates: emptyCoordinates)
    }

    // MARK: Private func
    func save<T: Codable>(object: T, filename: String) {
        let filePath = self.getDocumentsDirectoryUrl().appendingPathComponent(filename)
        print(filePath)
        do {
            let jsonData = try JSONEncoder().encode(object)
            try jsonData.write(to: filePath)
        } catch {
            print("Error writing to JSON file: \(error)")
        }
    }

    /// Новые объекты
    func getNewObjects() -> SportObjectResponse? {
        var documents = self.getDocumentsDirectoryUrl()
        documents.appendPathComponent(Config.kNewObjects + ".json")
        print(documents)
        do {
            let data = try Data(contentsOf: documents)
            let decoder = JSONDecoder()
            return try decoder.decode(SportObjectResponse.self, from: data)
        } catch {

        }
        return nil
    }

    /// Директория
    private func getDocumentsDirectoryUrl() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
}
