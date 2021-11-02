//
//  RatingRatingAssembly.swift
//  MosSportMap
//
//  Created by Sergey D on 02/11/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import UIKit
import Swinject

class RatingModule: Assembly {

    func assemble(container: Container) {
        container.register(RatingFactory.self) { r in
            return RatingFactory(container: container)
        }
        container.register(RatingViewController.self) { r in
            return RatingViewController()
        }.initCompleted { (r, viewController) in
            viewController.output = r.resolve(RatingPresenter.self)!
        }
        container.register(RatingRouter.self) { r in
            RatingRouter(viewController: r.resolve(RatingViewController.self)!)
        }
        container.register(RatingPresenter.self) { _ in RatingPresenter() }
            .initCompleted { (r, presenter) in
                presenter.router = r.resolve(RatingRouter.self)!
                presenter.interactor = r.resolve(RatingInteractor.self)!
                presenter.view = r.resolve(RatingViewController.self)!
        }
        container.register(RatingInteractor.self) { _ in RatingInteractor() }
            .initCompleted { (r, interactor) in
                interactor.output = r.resolve(RatingPresenter.self)!
        }
    }
}
