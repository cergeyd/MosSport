//
//  RatingInitialRatingInitialFactory.swift
//  MosSportMap
//
//  Created by Sergey D on 02/11/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import Swinject

class RatingInitialFactory {

    private weak var container: Container?

    public init(container: Container?) {
        self.container = container
    }

    func instantiateModule() -> RatingInitialViewController {
        guard let controller = container?.resolve(RatingInitialViewController.self) else {
            fatalError()
        }
        return controller
    }
}
