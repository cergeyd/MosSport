//
//  MapMapPresenter.swift
//  MosSportMap
//
//  Created by sergiusX on 14/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

class MapPresenter {
    var interactor: MapInteractorInput!
    var router: MapRouter!
    weak var view: MapViewInput!
}

extension MapPresenter: MapViewOutput {

    func didLoadView() {
        self.view.setupInitialState()
    }
    
    // MARK: Router
    func didTapShow(detail report: SquareReport) {
        self.router.didTapShow(detail: report)
    }
    
    func didTapShowRating() {
        self.router.didTapShowRating()
    }
    
    func didTapShow(sportObjects: [SportObject], department: Department) {
        self.router.didTapShow(sportObjects: sportObjects, department: department)
    }
    
    func didTapShow(sportObjects: [SportObject], type: SportType) {
        self.router.didTapShow(sportObjects: sportObjects, type: type)
    }
    
    func didTapShow(sport object: SportObject) {
        self.router.didTapShow(sport: object)
    }
}

extension MapPresenter: MapInteractorOutput {

    func response(error: Error) {

    }
}
