//
//  MosDataProcessing.swift
//  MosSportMap
//
//  Created by Sergeyd on 14.10.2021.
//

import Foundation
import RxSwift

var gSportTypes: SportTypeResponse!
var gDepartmentResponse: DepartmentResponse!
var gSportObjectResponse: SportObjectResponse!
var gPopulationResponse: PopulationResponse!

class MosDataProcessing {

    private let localService: LocalService
    let disposeBag = DisposeBag()

    //MARK: Init
    init(localService: LocalService) {
        self.localService = localService
        self.processedSportObjects()
    }

    /// Все данные
    private func processedSportObjects() {
        self.loadSportTypes()
        self.loadDepartments()
        self.loadSportObjects()
        self.loadPopulation()
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

    /// Директория
    private func getDocumentsDirectoryUrl() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
}
