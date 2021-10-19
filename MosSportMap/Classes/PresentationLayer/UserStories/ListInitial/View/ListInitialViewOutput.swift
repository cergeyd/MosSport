//
//  ListInitialListInitialViewOutput.swift
//  MosSportMap
//
//  Created by sergiusX on 17/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

protocol ListInitialViewOutput {
    func didLoadView()
    func listViewController(type: ListType, index: Int) -> ListViewController
}
