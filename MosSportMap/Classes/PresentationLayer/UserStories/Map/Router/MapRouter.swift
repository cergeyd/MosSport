//
//  MapMapRouter.swift
//  MosSportMap
//
//  Created by sergiusX on 14/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import UIKit

class MapRouter {
    private weak var viewController: MapViewController?
    private let detailFactory: DetailFactory
    private let listInitialFactory: ListInitialFactory

    init(viewController: MapViewController, detailFactory: DetailFactory, listInitialFactory: ListInitialFactory) {
        self.viewController = viewController
        self.detailFactory = detailFactory
        self.listInitialFactory = listInitialFactory
    }

    func didTapShow(detail report: SquareReport) {
        let detailController = self.detailFactory.instantiateModule()
        detailController.report = report
        self.show(detailController: detailController)
    }
    
    func didTapShow(sportObjects: [SportObject], type: SportType) {
        let detailController = self.detailFactory.instantiateModule()
        detailController.sportTypeSection = SportTypeSection(type: type, sportObjects: sportObjects)
        detailController.delegate = self.viewController
        self.show(detailController: detailController)
    }

    func didTapShow(sportObjects: [SportObject], department: Department) {
        let detailController = self.detailFactory.instantiateModule()
        detailController.section = DepartmentSection(department: department, sportObjects: sportObjects)
        detailController.delegate = self.viewController
        self.show(detailController: detailController)
    }

    private func show(detailController: UIViewController) {
        if let sheetController = detailController.sheetPresentationController {
            sheetController.detents = [.medium(), .large()]
            sheetController.largestUndimmedDetentIdentifier = .medium
            sheetController.prefersGrabberVisible = true
            sheetController.preferredCornerRadius = 22
        }
        self.viewController?.present(UINavigationController(rootViewController: detailController), animated: true)
    }

    func didTapShow(sport object: SportObject) {
        let controller = self.listInitialFactory.instantiateModule()
        controller.type = .sport(object: object)
        controller.listViewDelegate = self.viewController
        self.show(detailController: controller)
    }
}
