//
//  MosDataProcessing.swift
//  MosSportMap
//
//  Created by Sergeyd on 14.10.2021.
//

import Foundation
import RxSwift

var sportTypes: SportTypeResponse!
var departmentResponse: DepartmentResponse!
var sportObjectResponse: SportObjectResponse!
var populationResponse: PopulationResponse!

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
                populationResponse = PopulationResponse(populations: response.populations.sorted(by: { $0.population > $1.population }))
        }).disposed(by: self.disposeBag)
    }
    
    /// Виды спорта
    func loadSportTypes() {
        self.localService
            .loadSportTypes()
            .subscribe(onNext: { response in
            sportTypes = response
        }).disposed(by: self.disposeBag)
    }
    
    /// Департаменты
    func loadDepartments() {
        self.localService
            .loadDepartments()
            .subscribe(onNext: { response in
            departmentResponse = response
        }).disposed(by: self.disposeBag)
    }
    
    /// Спортивные объекты
    func loadSportObjects() {
        self.localService
            .loadSportObjects()
            .subscribe(onNext: { response in
            sportObjectResponse = response
        }).disposed(by: self.disposeBag)
    }
}
