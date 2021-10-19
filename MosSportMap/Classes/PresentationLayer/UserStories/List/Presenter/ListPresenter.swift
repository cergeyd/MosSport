//
//  ListListPresenter.swift
//  MosSportMap
//
//  Created by sergiusX on 17/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

class ListPresenter {
    var interactor: ListInteractorInput!
    var router: ListRouter!
    weak var view: ListViewInput!
}

extension ListPresenter: ListViewOutput {

    func didLoadView() {
        self.view.setupInitialState()
    }
    
    //MARK: Router
    func showListDetailScreen(with type: ListType) {
        self.router.showListDetailScreen(with: type)
    }
}

extension ListPresenter: ListInteractorOutput {

}
