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

    init(viewController: MenuViewController, calculatedFactory: CalculatedFactory) {
        self.viewController = viewController
        self.calculatedFactory = calculatedFactory
    }
    
    func calculatedViewController() -> CalculatedViewController {
        let controller = self.calculatedFactory.instantiateModule()
        controller.delegate = self.viewController
        return controller
    }
}
