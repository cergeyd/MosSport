//
//  ListInitialListInitialPresenter.swift
//  MosSportMap
//
//  Created by sergiusX on 17/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

class ListInitialPresenter {
    var interactor: ListInitialInteractorInput!
    var router: ListInitialRouter!
    weak var view: ListInitialViewInput!
}

extension ListInitialPresenter: ListInitialViewOutput {

    func didLoadView() {
        self.view.setupInitialState()
    }
    
    func listViewController(type: ListType, index: Int) -> ListViewController {
        return self.router.listViewController(type: type, index: index)
    }
}

extension ListInitialPresenter: ListInitialInteractorOutput {

}
