//
//  ListListAssembly.swift
//  MosSportMap
//
//  Created by sergiusX on 17/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import UIKit
import Swinject

class ListModule: Assembly {

    func assemble(container: Container) {
        container.register(ListFactory.self) { r in
            return ListFactory(container: container)
        }
        container.register(ListViewController.self) { r in
            return ListViewController()
        }.initCompleted { (r, viewController) in
            viewController.output = r.resolve(ListPresenter.self)!
        }
        container.register(ListRouter.self) { r in
            ListRouter(viewController: r.resolve(ListViewController.self)!, listFactory: r.resolve(ListFactory.self)!, listInitialFactory: r.resolve(ListInitialFactory.self)!)
        }
        container.register(ListPresenter.self) { _ in ListPresenter() }
            .initCompleted { (r, presenter) in
                presenter.router = r.resolve(ListRouter.self)!
                presenter.interactor = r.resolve(ListInteractor.self)!
                presenter.view = r.resolve(ListViewController.self)!
        }
        container.register(ListInteractor.self) { _ in ListInteractor() }
            .initCompleted { (r, interactor) in
                interactor.output = r.resolve(ListPresenter.self)!
        }
    }
}
