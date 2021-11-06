//
//  MenuMenuViewOutput.swift
//  MosSportMap
//
//  Created by sergiusX on 15/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

protocol MenuViewOutput {
    func didLoadView()
    func calculatedViewController() -> CalculatedViewController
    func recommendationViewController() -> RecommendationViewController
    func recommendationObjectViewController() -> RecommendationObjectViewController
    func didTapShow(listType: MenuType)
    func didTapSettings()
}
