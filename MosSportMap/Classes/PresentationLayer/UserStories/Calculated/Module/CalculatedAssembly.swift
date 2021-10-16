//
//  CalculatedCalculatedAssembly.swift
//  MosSportMap
//
//  Created by sergiusX on 15/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import UIKit
import Swinject

class CalculatedModule: Assembly {

    func assemble(container: Container) {
        container.register(CalculatedFactory.self) { r in
            return CalculatedFactory(container: container)
        }
        container.register(CalculatedViewController.self) { r in
            return CalculatedViewController()
        }.initCompleted { (r, viewController) in
            viewController.output = r.resolve(CalculatedPresenter.self)!
        }
        container.register(CalculatedRouter.self) { r in
            CalculatedRouter(viewController: r.resolve(CalculatedViewController.self)!)
        }
        container.register(CalculatedPresenter.self) { _ in CalculatedPresenter() }
            .initCompleted { (r, presenter) in
                presenter.router = r.resolve(CalculatedRouter.self)!
                presenter.interactor = r.resolve(CalculatedInteractor.self)!
                presenter.view = r.resolve(CalculatedViewController.self)!
        }
        container.register(CalculatedInteractor.self) { _ in CalculatedInteractor() }
            .initCompleted { (r, interactor) in
                interactor.output = r.resolve(CalculatedPresenter.self)!
        }
    }
}
