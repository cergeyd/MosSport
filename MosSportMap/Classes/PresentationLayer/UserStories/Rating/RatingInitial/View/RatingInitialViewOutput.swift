//
//  RatingInitialRatingInitialViewOutput.swift
//  MosSportMap
//
//  Created by Sergey D on 02/11/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

protocol RatingInitialViewOutput {
    func didLoadView()
    func ratingViewController(type: RateType) -> RatingViewController
}
