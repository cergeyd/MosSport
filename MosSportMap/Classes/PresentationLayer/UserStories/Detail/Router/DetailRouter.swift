//
//  DetailDetailRouter.swift
//  MosSportMap
//
//  Created by sergiusX on 15/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import UIKit

class DetailRouter {
    private weak var viewController: UIViewController?
    private let listInitialFactory: ListInitialFactory
    
    init(viewController: UIViewController, listInitialFactory: ListInitialFactory) {
        self.viewController = viewController
        self.listInitialFactory = listInitialFactory
    }

    func didTapShow(detail: Detail, report: SquareReport) {
        let controller = self.listInitialFactory.instantiateModule()
        controller.type = .details(detail: detail, report: report)
        self.viewController?.push(controller)
    }
}
