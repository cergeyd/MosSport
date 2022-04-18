//
//  MenuMenuPresenter.swift
//  MosSportMap
//
//  Created by sergiusX on 15/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

class MenuPresenter {
    var interactor: MenuInteractorInput!
    var router: MenuRouter!
    weak var view: MenuViewInput!
}

extension MenuPresenter: MenuViewOutput {

    func didLoadView() {
        self.view.setupInitialState()
    }
    
    // MARK: Router
    func calculatedViewController() -> CalculatedViewController {
        return self.router.calculatedViewController()
    }
    
    func recommendationViewController() -> RecommendationViewController {
        return self.router.recommendationViewController()
    }
    
    func recommendationObjectViewController() -> RecommendationObjectViewController {
        return self.router.recommendationObjectViewController()
    }
    
    func didTapShow(listType: MenuType)  {
        return self.router.didTapShow(listType: listType)
    }
    
    func didTapSettings() {
        self.router.didTapSettings()
    }
}

extension MenuPresenter: MenuInteractorOutput {

}
