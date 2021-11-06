//
//  RecommendationObjectRecommendationObjectFactory.swift
//  MosSportMap
//
//  Created by Sergey D on 06/11/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import Swinject

class RecommendationObjectFactory {

    private weak var container: Container?

    public init(container: Container?) {
        self.container = container
    }

    func instantiateModule() -> RecommendationObjectViewController {
        guard let controller = container?.resolve(RecommendationObjectViewController.self) else {
            fatalError()
        }
        return controller
    }
}
