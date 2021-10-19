//
//  ListInitialListInitialRouter.swift
//  MosSportMap
//
//  Created by sergiusX on 17/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import UIKit

class ListInitialRouter {
    private weak var viewController: UIViewController?
    private let listFactory: ListFactory

    init(viewController: UIViewController, listFactory: ListFactory) {
        self.viewController = viewController
        self.listFactory = listFactory
    }

    func listViewController(type: ListType, index: Int) -> ListViewController {
        let controller = self.listFactory.instantiateModule()
        controller.type = type
        controller.index = index
        return controller
    }
}
