//
//  CalculatedCalculatedFactory.swift
//  MosSportMap
//
//  Created by sergiusX on 15/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import Swinject

class CalculatedFactory {

    private weak var container: Container?

    public init(container: Container?) {
        self.container = container
    }

    func instantiateModule() -> CalculatedViewController {
        guard let controller = container?.resolve(CalculatedViewController.self) else {
            fatalError()
        }
        return controller
    }
}
