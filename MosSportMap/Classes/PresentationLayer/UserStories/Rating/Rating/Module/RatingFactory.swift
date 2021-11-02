//
//  RatingRatingFactory.swift
//  MosSportMap
//
//  Created by Sergey D on 02/11/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import Swinject

class RatingFactory {

    private weak var container: Container?

    public init(container: Container?) {
        self.container = container
    }

    func instantiateModule() -> RatingViewController {
        guard let controller = container?.resolve(RatingViewController.self) else {
            fatalError()
        }
        return controller
    }
}
