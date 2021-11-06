//
//  RecommendationObjectRecommendationObjectAssembly.swift
//  MosSportMap
//
//  Created by Sergey D on 06/11/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import UIKit
import Swinject

class RecommendationObjectModule: Assembly {

    func assemble(container: Container) {
        container.register(RecommendationObjectFactory.self) { r in
            return RecommendationObjectFactory(container: container)
        }
        container.register(RecommendationObjectViewController.self) { r in
            return RecommendationObjectViewController()
        }.initCompleted { (r, viewController) in
            viewController.output = r.resolve(RecommendationObjectPresenter.self)!
        }
        container.register(RecommendationObjectRouter.self) { r in
            RecommendationObjectRouter(viewController: r.resolve(RecommendationObjectViewController.self)!, recommendationObjectFactory: r.resolve(RecommendationObjectFactory.self)!)
        }
        container.register(RecommendationObjectPresenter.self) { _ in RecommendationObjectPresenter() }
            .initCompleted { (r, presenter) in
                presenter.router = r.resolve(RecommendationObjectRouter.self)!
                presenter.interactor = r.resolve(RecommendationObjectInteractor.self)!
                presenter.view = r.resolve(RecommendationObjectViewController.self)!
        }
        container.register(RecommendationObjectInteractor.self) { _ in RecommendationObjectInteractor() }
            .initCompleted { (r, interactor) in
                interactor.output = r.resolve(RecommendationObjectPresenter.self)!
        }
    }
}
