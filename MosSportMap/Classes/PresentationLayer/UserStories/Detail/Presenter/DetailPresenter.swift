//
//  DetailDetailPresenter.swift
//  MosSportMap
//
//  Created by sergiusX on 15/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

class DetailPresenter {
    var interactor: DetailInteractorInput!
    var router: DetailRouter!
    weak var view: DetailViewInput!
}

extension DetailPresenter: DetailViewOutput {

    func didLoadView() {
        self.view.setupInitialState()
    }

    func didTapShow(detail: Detail) {
        self.router.didTapShow(detail: detail)
    }
}

extension DetailPresenter: DetailInteractorOutput {

}