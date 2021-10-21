//
//  RecommendationRecommendationRouter.swift
//  MosSportMap
//
//  Created by sergiusX on 21/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import UIKit

class RecommendationRouter {
    private weak var viewController: RecommendationViewController?
    private let recommendationFactory: RecommendationFactory
    
    init(viewController: RecommendationViewController, recommendationFactory: RecommendationFactory) {
        self.viewController = viewController
        self.recommendationFactory = recommendationFactory
    }

    func didSelect(recommendationType: RecommendationType) {
        let controller = self.recommendationFactory.instantiateModule()
        controller.recommendationType = recommendationType
        controller.delegate = self.viewController?.delegate
        self.viewController?.push(controller)
    }
}
