//
//  ListListFactory.swift
//  MosSportMap
//
//  Created by sergiusX on 17/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import Swinject

class ListFactory {

    private weak var container: Container?

    public init(container: Container?) {
        self.container = container
    }

    func instantiateModule() -> ListViewController {
        guard let controller = container?.resolve(ListViewController.self) else {
            fatalError()
        }
        return controller
    }
}
