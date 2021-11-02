//
//  RatingInitialRatingInitialRouter.swift
//  MosSportMap
//
//  Created by Sergey D on 02/11/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import UIKit

class RatingInitialRouter {
    private weak var viewController: UIViewController?
    private let ratingFactory: RatingFactory

    init(viewController: UIViewController, ratingFactory: RatingFactory) {
        self.viewController = viewController
        self.ratingFactory = ratingFactory
    }

    func ratingViewController(type: RateType) -> RatingViewController {
        let controller = self.ratingFactory.instantiateModule()
        controller.type = type
        return controller
    }
}
