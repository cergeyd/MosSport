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
    private let listFactory: ListFactory

    init(viewController: MenuViewController, calculatedFactory: CalculatedFactory, listFactory: ListFactory) {
        self.viewController = viewController
        self.calculatedFactory = calculatedFactory
        self.listFactory = listFactory
    }

    func calculatedViewController() -> CalculatedViewController {
        let controller = self.calculatedFactory.instantiateModule()
        controller.delegate = self.viewController
        return controller
    }

    func didTapShow(listType: MenuType) {
        let controller = self.listFactory.instantiateModule()
        controller.delegate = self.viewController
        switch listType {
        case .filterAreas:
            controller.type = .filterAreas
        case .filterSportTypes:
            controller.type = .filterSportTypes
        case .filterObjects:
            controller.type = .filterObjects(items: sportObjectResponse.objects)
        default:
            controller.type = .filterDepartments
        }
        self.viewController?.push(controller)
    }
}
