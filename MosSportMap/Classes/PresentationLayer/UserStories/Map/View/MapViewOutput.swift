//
//  MapMapViewOutput.swift
//  MosSportMap
//
//  Created by sergiusX on 14/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

protocol MapViewOutput {
    func didLoadView()
    func didTapShow(detail report: SquareReport)
    func didTapShowRating()
    func didTapShow(sportObjects: [SportObject], department: Department)
    func didTapShow(sportObjects: [SportObject], type: SportType)
    func didTapShow(sport object: SportObject)
}
