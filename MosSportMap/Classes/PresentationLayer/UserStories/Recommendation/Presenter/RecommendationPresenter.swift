//
//  RecommendationRecommendationPresenter.swift
//  MosSportMap
//
//  Created by sergiusX on 21/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

class RecommendationPresenter {
    var interactor: RecommendationInteractorInput!
    var router: RecommendationRouter!
    weak var view: RecommendationViewInput!
}

extension RecommendationPresenter: RecommendationViewOutput {

    func didLoadView() {
        self.view.setupInitialState()
    }
    
    // MARK: Router
    func didSelect(recommendationType: RecommendationType) {
        self.router.didSelect(recommendationType: recommendationType)
    }
}

extension RecommendationPresenter: RecommendationInteractorOutput {

}
