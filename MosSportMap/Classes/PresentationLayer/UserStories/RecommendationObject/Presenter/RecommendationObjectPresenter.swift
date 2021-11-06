//
//  RecommendationObjectRecommendationObjectPresenter.swift
//  MosSportMap
//
//  Created by Sergey D on 06/11/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

class RecommendationObjectPresenter {
    var interactor: RecommendationObjectInteractorInput!
    var router: RecommendationObjectRouter!
    weak var view: RecommendationObjectViewInput!
}

extension RecommendationObjectPresenter: RecommendationObjectViewOutput {

    func didLoadView() {
        self.view.setupInitialState()
    }

    func didSelect(recommendationType: RecommendationSportObjectType) {
        self.router.didSelect(recommendationType: recommendationType)
    }
}

extension RecommendationObjectPresenter: RecommendationObjectInteractorOutput {

}
