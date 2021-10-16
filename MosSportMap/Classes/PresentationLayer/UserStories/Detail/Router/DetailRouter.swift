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

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    func didTapShow(detail: Detail) {
        let controller = ListViewController()
        controller.type = .details(detail: detail)
        self.viewController?.push(controller)
    }
}
