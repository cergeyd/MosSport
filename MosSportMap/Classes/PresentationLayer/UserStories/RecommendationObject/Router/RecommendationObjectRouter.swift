//
//  RecommendationObjectRecommendationObjectRouter.swift
//  MosSportMap
//
//  Created by Sergey D on 06/11/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import UIKit

class RecommendationObjectRouter {
    private weak var viewController: RecommendationObjectViewController?
    private let recommendationObjectFactory: RecommendationObjectFactory
    
    init(viewController: RecommendationObjectViewController, recommendationObjectFactory: RecommendationObjectFactory) {
        self.viewController = viewController
        self.recommendationObjectFactory = recommendationObjectFactory
    }
    
    func didSelect(recommendationType: RecommendationSportObjectType) {
        let controller = self.recommendationObjectFactory.instantiateModule()
        controller.recommendationType = recommendationType
        controller.delegate = self.viewController?.delegate
        self.viewController?.push(controller)
    }
}
