//
//  ListListRouter.swift
//  MosSportMap
//
//  Created by sergiusX on 17/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import UIKit

class ListRouter {
    private weak var viewController: ListViewController?
    private let listFactory: ListFactory
    private let listInitialFactory: ListInitialFactory

    init(viewController: ListViewController, listFactory: ListFactory, listInitialFactory: ListInitialFactory) {
        self.viewController = viewController
        self.listFactory = listFactory
        self.listInitialFactory = listInitialFactory
    }

    func showListDetailScreen(with type: ListType) {
        switch type {
        case .sportObjectsAround:
            self.showInitialListDetailScreen(with: type)
        default:
            let controller = self.listFactory.instantiateModule()
            controller.type = type
            self.viewController?.push(controller)
        }
    }

    //MARK: Private func
    private func showInitialListDetailScreen(with type: ListType) {
        let controller = self.listInitialFactory.instantiateModule()
        controller.type = type
        controller.listViewDelegate = self.viewController?.delegate
        self.viewController?.push(controller)
    }
}
