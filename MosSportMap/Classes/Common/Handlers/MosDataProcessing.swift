//
//  MosDataProcessing.swift
//  MosSportMap
//
//  Created by Sergeyd on 14.10.2021.
//

import Foundation
import RxSwift
import CoreLocation

var gSportTypes: SportTypeResponse!
var gDepartmentResponse: DepartmentResponse!
var gSportObjectResponse: SportObjectResponse!
var gSportOSMObjectResponse: SportObjectResponse!
var gPopulationResponse: PopulationResponse!

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

class MosDataProcessing {

    private let localService: LocalService
    let disposeBag = DisposeBag()

    //MARK: Init
    init(localService: LocalService) {
        self.localService = localService
        self.processedSportObjects()
//        Dispatch.after(10.0) {
//            self.createPop()
//        }

//        Dispatch.after(10.0) {
//            self.makeRectangles()
//        }
    }

    func makeRectangles() {
        var responses: [RectangleOldResponse] = []
        for population in gPopulationResponse.populations {
            var rects: [RectangleOld] = []
            let polygon = SharedManager.shared.allPolygons.first { p in
                return p.title! == population.area
            }!
            let rec = SharedManager.shared.getRectangle(inside: polygon)
            rects.append(RectangleOld(topLeftLati: rec.topLeft.latitude, topLeftLong: rec.topLeft.longitude, bottomRightLati: rec.bottomRight.latitude, bottomRightLong: rec.bottomRight.longitude))
            responses.append(RectangleOldResponse(population: population, rectangles: rects))
        }
        self.save(object: responses, filename: "rectangles")
    }

    func makeRating() -> [Rating] {
        var allReports: [SquareReport] = []
        for population in gPopulationResponse.populations {
            let polygon = SharedManager.shared.allPolygons.first { p in
                return p.title! == population.area
            }
            let report = SharedManager.shared.calculateReport(for: population, polygon: polygon!)
            allReports.append(report)
        }

        let currentSortPop = allReports.sorted(by: { $0.population.population > $1.population.population })
        let currentSortSquare = allReports.sorted(by: { $0.population.square > $1.population.square })
        let currentSortObjects = allReports.sorted(by: { $0.objects.count > $1.objects.count })
        let currentSortSportSquare = allReports.sorted(by: { $0.allSquare > $1.allSquare })
        let currentSortTypes = allReports.sorted(by: { $0.sportTypes.count > $1.sportTypes.count })
        let currentSortSquareForOne = allReports.sorted(by: { $0.squareForOne > $1.squareForOne })
        let currentSortSportForOne = allReports.sorted(by: { $0.sportForOne > $1.sportForOne })
        let currentSortObjectForOne = allReports.sorted(by: { $0.objectForOne > $1.objectForOne })

        var reports: [Rating] = []

        for population in gPopulationResponse.populations {

            let report = Rating()
            report.population = population

            /// Место района по численности
            for (ind, value) in currentSortPop.enumerated() {
                if (value.population == population) {
                    report.placeByPopulation = ind + 1
                    report.placeByPopulationValue = value.population.population
                }
            }

            /// Место района по площади
            for (ind, value) in currentSortSquare.enumerated() {
                if (value.population == population) {
                    report.placeBySquare = ind + 1
                    report.placeBySquareValue = value.population.square
                }
            }

            /// Место района по спортивным объектам
            for (ind, value) in currentSortObjects.enumerated() {
                if (value.population == population) {
                    report.placebySportObjects = ind
                    report.placebySportObjectsValue = value.sports.count
                }
            }

            /// Место района по площади спортивных объектов
            for (ind, value) in currentSortSportSquare.enumerated() {
                if (value.population == population) {
                    report.placeBySportSquare = ind + 1
                    report.placeBySportSquareValue = value.allSquare
                }
            }

            /// Место района по спортивным видам
            for (ind, value) in currentSortTypes.enumerated() {
                if (value.population == population) {
                    report.placeBySportTypes = ind + 1
                    report.placeBySportTypesValue = value.sportTypes.count
                }
            }

            /// Место района по площади спортивных районов на одного
            for (ind, value) in currentSortSquareForOne.enumerated() {
                if (value.population == population) {
                    report.placeBySquareForOne = ind + 1
                    report.placeBySquareForOneValue = value.squareForOne
                }
            }

            /// Место района по видам спорта на одного
            for (ind, value) in currentSortSportForOne.enumerated() {
                if (value.population == population) {
                    report.placeBySportForOne = ind + 1
                    report.placeBySportForOneValue = value.sportTypeForOne
                }
            }

            /// Место района по спортивным объектам на одного
            for (ind, value) in currentSortObjectForOne.enumerated() {
                if (value.population == population) {
                    report.placeByObjectForOne = ind + 1
                    report.placeByObjectForOneValue = value.objectForOne
                }
            }

            reports.append(report)
        }

        return reports
    }

    private func createPop() {
        let reports = self.makeRating()
        var new: [Population] = []

        for population in gPopulationResponse.populations {
            let r = reports.first { r in
                return r.population == population
            }!
            let rating = Population.Rating.init(
                placeByPopulation: r.placeByPopulation,
                placeByPopulationValue: r.placeByPopulationValue,

                placeBySquare: r.placeBySquare,
                placeBySquareValue: r.placeBySquareValue,

                placebySportObjects: r.placebySportObjects,
                placebySportObjectsValue: r.placebySportObjectsValue,

                placeBySportSquare: r.placeBySportSquare,
                placeBySportSquareValue: r.placeBySportSquareValue,

                placeBySportTypes: r.placeBySportTypes,
                placeBySportTypesValue: r.placeBySportTypesValue,

                placeBySquareForOne: r.placeBySquareForOne,
                placeBySquareForOneValue: r.placeBySquareForOneValue,

                placeBySportForOne: r.placeBySportForOne,
                placeBySportForOneValue: r.placeBySportForOneValue,

                placeByObjectForOne: r.placeByObjectForOne,
                placeByObjectForOneValue: r.placeByObjectForOneValue
            )

            let n = Population(area: population.area, population: population.population, square: population.square, latitude: population.latitude, longitude: population.longitude, rating: rating)
            new.append(n)
        }

        let news = new.sorted(by: { $0.population > $1.population })
        let response = PopulationResponse(populations: news)
        self.save(object: response, filename: "newPop")
    }

    /// Все данные
    private func processedSportObjects() {
        self.loadSportTypes()
        self.loadDepartments()
        self.loadSportObjects()
        self.loadPopulation()
        self.loadOSMSportObjects()
    }

    /// Численность населения Москвы
    func loadPopulation() {
        self.localService
            .loadPopulation()
            .subscribe(onNext: { response in
            gPopulationResponse = response
        }).disposed(by: self.disposeBag)
    }

    /// Виды спорта
    func loadSportTypes() {
        self.localService
            .loadSportTypes()
            .subscribe(onNext: { response in
            gSportTypes = response
        }).disposed(by: self.disposeBag)
    }

    /// Департаменты
    func loadDepartments() {
        self.localService
            .loadDepartments()
            .subscribe(onNext: { response in
            gDepartmentResponse = response
        }).disposed(by: self.disposeBag)
    }

    /// Спортивные объекты
    func loadSportObjects() {
        self.localService
            .loadSportObjects()
            .subscribe(onNext: { response in
            gSportObjectResponse = response
        }).disposed(by: self.disposeBag)
    }

    /// Спортивные объекты дополнительные
    func loadOSMSportObjects() {
        self.localService
            .loadOSMSportObjects()
            .subscribe(onNext: { response in
            gSportOSMObjectResponse = response
                gSportObjectResponse = response

                //gSportObjectResponse.objects.append(contentsOf: response.objects)
           // self.check(response: response)
        }).disposed(by: self.disposeBag)
    }

    func check(response: SportObjectResponse) {
        var all: [SportObject] = []
        var objects = response.objects

        for o in objects {
            let nonUniq = gSportObjectResponse.objects.filter { object in
                let isEqual = o.coorditate.latitude == object.coorditate.latitude && o.coorditate.longitude == object.coorditate.longitude

                let existLocation = CLLocation(latitude: object.coordinate.latitude, longitude: object.coordinate.longitude)
                let missLocation = CLLocation(latitude: o.coordinate.latitude, longitude: o.coordinate.longitude)

                let distance = existLocation.distance(from: missLocation)
//                if (distance < 135) {
//                    print(distance)
//                }
                return (distance < 135) || isEqual
            }
            for (ind, value) in nonUniq.enumerated() {
                //if (ind > 0) {
                    all.append(o)
               // }
            }
        }
        print(all.count)

        var new: [SportObject] = []

        for (ind, value) in objects.enumerated() {
            if (all.contains(where: { object in
                return object.id == value.id
            })) {
                //objects.remove(at: ind)
            } else {
                new.append(value)
            }
        }
        print(new.count)
        let resp = SportObjectResponse(objects: new)
        self.save(object: resp, filename: "newresp")

//        var all: [SportObject] = []
//        var objects = response.objects
//
//        for o in response.objects {
//            let nonUniq = response.objects.filter { object in
//                return o.coorditate.latitude == object.coorditate.latitude && o.coorditate.longitude == object.coorditate.longitude
//            }
//            for (ind, value) in nonUniq.enumerated() {
//                if (ind > 0) {
//                    all.append(value)
//                }
//            }
//        }
//        print(all.count)
//
//        var new: [SportObject] = []
//
//        for (ind, value) in objects.enumerated() {
//            if (all.contains(where: { object in
//                return object.id == value.id
//            })) {
//                //objects.remove(at: ind)
//            } else {
//                new.append(value)
//            }
//        }
//        print(new.count)
//        let resp = SportObjectResponse(objects: new)
//        self.save(object: resp, filename: "newresp")
    }

    //MARK: Private func
    private func save<T: Codable>(object: T, filename: String) {
        let filePath = self.getDocumentsDirectoryUrl().appendingPathComponent(filename)
        print(filePath)
        do {
            let jsonData = try JSONEncoder().encode(object)
            try jsonData.write(to: filePath)
        } catch {
            print("Error writing to JSON file: \(error)")
        }
    }

    /// Директория
    private func getDocumentsDirectoryUrl() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
}
