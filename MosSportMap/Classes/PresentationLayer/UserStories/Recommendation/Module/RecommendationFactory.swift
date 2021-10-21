//
//  RecommendationRecommendationFactory.swift
//  MosSportMap
//
//  Created by sergiusX on 21/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import Swinject

class RecommendationFactory {

    private weak var container: Container?

    public init(container: Container?) {
        self.container = container
    }

    func instantiateModule() -> RecommendationViewController {
        guard let controller = container?.resolve(RecommendationViewController.self) else {
            fatalError()
        }
        return controller
    }
}
