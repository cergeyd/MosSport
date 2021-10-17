//
//  LocalService.swift
//  MosSportMap
//
//  Created by sergiusX on 15/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import RxSwift

class LocalService {

    private let localeJSONHelper: LocaleJSONHelper
    private let fileNameSportObjects = "sportObjects"
    private let fileNameSportTypes = "sportTypes"
    private let fileNameDepartments = "departments"
    private let fileNamePopulation = "moscowPopulation"

    init(localeJSONHelper: LocaleJSONHelper) {
        self.localeJSONHelper = localeJSONHelper
    }

    func loadSportObjects() -> Observable<SportObjectResponse> {
        return self.localeJSONHelper
            .loadJson(with: self.fileNameSportObjects)
            .map { (json) -> SportObjectResponse in
            let result = try CodableMapper<SportObjectResponse>().map(JSONObject: json as! [String: Any])
            return result
        }
    }

    func loadPopulation() -> Observable<PopulationResponse> {
        return self.localeJSONHelper
            .loadJson(with: self.fileNamePopulation)
            .map { (json) -> PopulationResponse in
            let result = try CodableMapper<PopulationResponse>().map(JSONObject: json as! [String: Any])
            return result
        }
    }

    func loadSportTypes() -> Observable<SportTypeResponse> {
        return self.localeJSONHelper
            .loadJson(with: self.fileNameSportTypes)
            .map { (json) -> SportTypeResponse in
            let result = try CodableMapper<SportTypeResponse>().map(JSONObject: json as! [String: Any])
            return result
        }
    }

    func loadDepartments() -> Observable<DepartmentResponse> {
        return self.localeJSONHelper
            .loadJson(with: self.fileNameDepartments)
            .map { (json) -> DepartmentResponse in
            let result = try CodableMapper<DepartmentResponse>().map(JSONObject: json as! [String: Any])
            return result
        }
    }
}
