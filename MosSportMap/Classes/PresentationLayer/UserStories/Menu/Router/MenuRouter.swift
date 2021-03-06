//
//  MenuMenuRouter.swift
//  MosSportMap
//
//  Created by sergiusX on 15/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import UIKit

class MenuRouter {
    private weak var viewController: MenuViewController?
    private let calculatedFactory: CalculatedFactory
    private let recommendationFactory: RecommendationFactory
    private let recommendationObjectFactory: RecommendationObjectFactory
    private let listFactory: ListFactory
    private let settingsFactory: SettingsFactory

    init(viewController: MenuViewController, calculatedFactory: CalculatedFactory, listFactory: ListFactory, recommendationFactory: RecommendationFactory, settingsFactory: SettingsFactory, recommendationObjectFactory: RecommendationObjectFactory) {
        self.viewController = viewController
        self.recommendationFactory = recommendationFactory
        self.calculatedFactory = calculatedFactory
        self.settingsFactory = settingsFactory
        self.recommendationObjectFactory = recommendationObjectFactory
        self.listFactory = listFactory
    }

    func recommendationViewController() -> RecommendationViewController {
        let controller = self.recommendationFactory.instantiateModule()
        controller.delegate = self.viewController
        return controller
    }

    func recommendationObjectViewController() -> RecommendationObjectViewController {
        let controller = self.recommendationObjectFactory.instantiateModule()
        controller.delegate = self.viewController
        return controller
    }

    func calculatedViewController() -> CalculatedViewController {
        let controller = self.calculatedFactory.instantiateModule()
        controller.delegate = self.viewController
        return controller
    }

    func didTapSettings() {
        let controller = self.settingsFactory.instantiateModule()
        self.viewController?.push(controller)
    }

    func didTapShow(listType: MenuType) {
        let controller = self.listFactory.instantiateModule()
        controller.delegate = self.viewController
        switch listType {
        case .filterAreas:
            controller.type = .filterAreas
        case .filterDepartments:
            controller.type = .filterDepartments
        case .filterSportTypes:
            controller.type = .filterSportTypes
        case .filterObjects:
            controller.type = .filterObjects(items: gSportObjectResponse.objects)
        case .recNewObjects:
            controller.type = .filterDepartments
        default:
            controller.type = .rating
        }
        self.viewController?.push(controller)
    }
}
