//
//  DetailDetailViewOutput.swift
//  MosSportMap
//
//  Created by sergiusX on 15/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

protocol DetailViewOutput {
    func didLoadView()
    func didTapShow(detail: Detail, report: SquareReport)
}
