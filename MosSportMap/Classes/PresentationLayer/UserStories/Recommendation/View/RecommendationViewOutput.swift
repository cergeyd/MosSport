//
//  RecommendationRecommendationViewOutput.swift
//  MosSportMap
//
//  Created by sergiusX on 21/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

protocol RecommendationViewOutput {
    func didLoadView()
    func didSelect(recommendationType: RecommendationType)
}
