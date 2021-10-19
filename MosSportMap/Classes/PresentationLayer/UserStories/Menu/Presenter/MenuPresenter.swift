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
    
    func calculatedViewController() -> CalculatedViewController {
        return self.router.calculatedViewController()
    }
    
    func didTapShow(listType: MenuType)  {
        return self.router.didTapShow(listType: listType)
    }
}

extension MenuPresenter: MenuInteractorOutput {

}
