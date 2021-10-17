//
//  MenuMenuAssembly.swift
//  MosSportMap
//
//  Created by sergiusX on 15/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import UIKit
import Swinject

class MenuModule: Assembly {

    func assemble(container: Container) {
        container.register(MenuFactory.self) { r in
            return MenuFactory(container: container)
        }
        container.register(MenuViewController.self) { r in
            return MenuViewController()
        }.initCompleted { (r, viewController) in
            viewController.output = r.resolve(MenuPresenter.self)!
        }
        container.register(MenuRouter.self) { r in
            MenuRouter(viewController: r.resolve(MenuViewController.self)!, calculatedFactory: r.resolve(CalculatedFactory.self)!, listFactory: r.resolve(ListFactory.self)!)
        }
        container.register(MenuPresenter.self) { _ in MenuPresenter() }
            .initCompleted { (r, presenter) in
                presenter.router = r.resolve(MenuRouter.self)!
                presenter.interactor = r.resolve(MenuInteractor.self)!
                presenter.view = r.resolve(MenuViewController.self)!
        }
        container.register(MenuInteractor.self) { _ in MenuInteractor() }
            .initCompleted { (r, interactor) in
                interactor.output = r.resolve(MenuPresenter.self)!
        }
    }
}
