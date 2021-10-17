//
//  ListInitialListInitialAssembly.swift
//  MosSportMap
//
//  Created by sergiusX on 17/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import UIKit
import Swinject

class ListInitialModule: Assembly {

    func assemble(container: Container) {
        container.register(ListInitialFactory.self) { r in
            return ListInitialFactory(container: container)
        }
        container.register(ListInitialViewController.self) { r in
            return ListInitialViewController()
        }.initCompleted { (r, viewController) in
            viewController.output = r.resolve(ListInitialPresenter.self)!
        }
        container.register(ListInitialRouter.self) { r in
            ListInitialRouter(viewController: r.resolve(ListInitialViewController.self)!, listFactory: r.resolve(ListFactory.self)!)
        }
        container.register(ListInitialPresenter.self) { _ in ListInitialPresenter() }
            .initCompleted { (r, presenter) in
                presenter.router = r.resolve(ListInitialRouter.self)!
                presenter.interactor = r.resolve(ListInitialInteractor.self)!
                presenter.view = r.resolve(ListInitialViewController.self)!
        }
        container.register(ListInitialInteractor.self) { _ in ListInitialInteractor() }
            .initCompleted { (r, interactor) in
                interactor.output = r.resolve(ListInitialPresenter.self)!
        }
    }
}
