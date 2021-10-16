//
//  CalculatedCalculatedPresenter.swift
//  MosSportMap
//
//  Created by sergiusX on 15/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

class CalculatedPresenter {
    var interactor: CalculatedInteractorInput!
    var router: CalculatedRouter!
    weak var view: CalculatedViewInput!
}

extension CalculatedPresenter: CalculatedViewOutput {

    func didLoadView() {
        self.view.setupInitialState()
    }
}

extension CalculatedPresenter: CalculatedInteractorOutput {

}
