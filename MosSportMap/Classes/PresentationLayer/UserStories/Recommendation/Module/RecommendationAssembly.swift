//
//  RecommendationRecommendationAssembly.swift
//  MosSportMap
//
//  Created by sergiusX on 21/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import UIKit
import Swinject

class RecommendationModule: Assembly {

    func assemble(container: Container) {
        container.register(RecommendationFactory.self) { r in
            return RecommendationFactory(container: container)
        }
        container.register(RecommendationViewController.self) { r in
            return RecommendationViewController()
        }.initCompleted { (r, viewController) in
            viewController.output = r.resolve(RecommendationPresenter.self)!
        }
        container.register(RecommendationRouter.self) { r in
            RecommendationRouter(viewController: r.resolve(RecommendationViewController.self)!, recommendationFactory: r.resolve(RecommendationFactory.self)!)
        }
        container.register(RecommendationPresenter.self) { _ in RecommendationPresenter() }
            .initCompleted { (r, presenter) in
                presenter.router = r.resolve(RecommendationRouter.self)!
                presenter.interactor = r.resolve(RecommendationInteractor.self)!
                presenter.view = r.resolve(RecommendationViewController.self)!
        }
        container.register(RecommendationInteractor.self) { _ in RecommendationInteractor() }
            .initCompleted { (r, interactor) in
                interactor.output = r.resolve(RecommendationPresenter.self)!
        }
    }
}
