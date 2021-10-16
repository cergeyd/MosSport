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
    
    func didTapShow(detail report: SquareReport) {
        self.router.didTapShow(detail: report)
    }
}

extension MapPresenter: MapInteractorOutput {

    func response(error: Error) {
        self.view.response(error: error)
    }
}
