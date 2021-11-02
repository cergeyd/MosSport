//
//  RatingInitialRatingInitialAssembly.swift
//  MosSportMap
//
//  Created by Sergey D on 02/11/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import UIKit
import Swinject

class RatingInitialModule: Assembly {

    func assemble(container: Container) {
        container.register(RatingInitialFactory.self) { r in
            return RatingInitialFactory(container: container)
        }
        container.register(RatingInitialViewController.self) { r in
            return RatingInitialViewController()
        }.initCompleted { (r, viewController) in
            viewController.output = r.resolve(RatingInitialPresenter.self)!
        }
        container.register(RatingInitialRouter.self) { r in
            RatingInitialRouter(viewController: r.resolve(RatingInitialViewController.self)!, ratingFactory: r.resolve(RatingFactory.self)!)
        }
        container.register(RatingInitialPresenter.self) { r in RatingInitialPresenter() }
            .initCompleted { (r, presenter) in
                presenter.router = r.resolve(RatingInitialRouter.self)!
                presenter.interactor = r.resolve(RatingInitialInteractor.self)!
                presenter.view = r.resolve(RatingInitialViewController.self)!
        }
        container.register(RatingInitialInteractor.self) { _ in RatingInitialInteractor() }
            .initCompleted { (r, interactor) in
                interactor.output = r.resolve(RatingInitialPresenter.self)!
        }
    }
}
