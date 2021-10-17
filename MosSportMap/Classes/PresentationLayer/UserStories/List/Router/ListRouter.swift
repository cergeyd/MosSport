//
//  ListListRouter.swift
//  MosSportMap
//
//  Created by sergiusX on 17/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import UIKit

class ListRouter {
    private weak var viewController: UIViewController?
    private let listFactory: ListFactory

    init(viewController: UIViewController, listFactory: ListFactory) {
        self.viewController = viewController
        self.listFactory = listFactory
    }

    func showListDetailScreen(with type: ListType) {
       // let controller = self.listInitialFactory.instantiateModule()
       // controller.type = type
       // self.viewController?.push(controller)
    }
}
