//
//  RatingRatingPresenter.swift
//  MosSportMap
//
//  Created by Sergey D on 02/11/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

class RatingPresenter {
    var interactor: RatingInteractorInput!
    var router: RatingRouter!
    weak var view: RatingViewInput!
}

extension RatingPresenter: RatingViewOutput {

    func didLoadView() {
        self.view.setupInitialState()
    }
}

extension RatingPresenter: RatingInteractorOutput {

}
