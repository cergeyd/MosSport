//
//  DetailDetailAssembly.swift
//  MosSportMap
//
//  Created by sergiusX on 15/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import UIKit
import Swinject

class DetailModule: Assembly {

    func assemble(container: Container) {
        container.register(DetailFactory.self) { r in
            return DetailFactory(container: container)
        }
        container.register(DetailViewController.self) { r in
            return DetailViewController()
        }.initCompleted { (r, viewController) in
            viewController.output = r.resolve(DetailPresenter.self)!
        }
        container.register(DetailRouter.self) { r in
            DetailRouter(viewController: r.resolve(DetailViewController.self)!)
        }
        container.register(DetailPresenter.self) { _ in DetailPresenter() }
            .initCompleted { (r, presenter) in
                presenter.router = r.resolve(DetailRouter.self)!
                presenter.interactor = r.resolve(DetailInteractor.self)!
                presenter.view = r.resolve(DetailViewController.self)!
        }
        container.register(DetailInteractor.self) { _ in DetailInteractor() }
            .initCompleted { (r, interactor) in
                interactor.output = r.resolve(DetailPresenter.self)!
        }
    }
}
