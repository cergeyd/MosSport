//
//  RatingInitialRatingInitialPresenter.swift
//  MosSportMap
//
//  Created by Sergey D on 02/11/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

class RatingInitialPresenter {
    var interactor: RatingInitialInteractorInput!
    var router: RatingInitialRouter!
    weak var view: RatingInitialViewInput!
}

extension RatingInitialPresenter: RatingInitialViewOutput {

    func didLoadView() {
        self.view.setupInitialState()
    }
    
    func ratingViewController(type: RateType) -> RatingViewController {
        return self.router.ratingViewController(type: type)
    }
}

extension RatingInitialPresenter: RatingInitialInteractorOutput {

}
