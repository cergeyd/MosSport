//
//  MapMapRouter.swift
//  MosSportMap
//
//  Created by sergiusX on 14/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import UIKit

class MapRouter {
    private weak var viewController: UIViewController?
    private let detailFactory: DetailFactory

    init(viewController: UIViewController, detailFactory: DetailFactory) {
        self.viewController = viewController
        self.detailFactory = detailFactory
    }

    func didTapShow(detail report: SquareReport) {
        let detailController = self.detailFactory.instantiateModule()
        detailController.report = report
        if let sheetController = detailController.sheetPresentationController {
            sheetController.detents = [.medium(), .large()]
            sheetController.largestUndimmedDetentIdentifier = .medium
            sheetController.prefersGrabberVisible = true
            sheetController.preferredCornerRadius = 22
        }
        self.viewController?.present(UINavigationController(rootViewController: detailController), animated: true)
    }
}
