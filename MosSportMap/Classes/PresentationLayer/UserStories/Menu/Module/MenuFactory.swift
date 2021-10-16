//
//  MenuMenuFactory.swift
//  MosSportMap
//
//  Created by sergiusX on 15/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import Swinject

class MenuFactory {

    private weak var container: Container?

    public init(container: Container?) {
        self.container = container
    }

    func instantiateModule() -> MenuViewController {
        guard let controller = container?.resolve(MenuViewController.self) else {
            fatalError()
        }
        return controller
    }
}
