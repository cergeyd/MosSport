//
//  DetailDetailFactory.swift
//  MosSportMap
//
//  Created by sergiusX on 15/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import Swinject

class DetailFactory {

    private weak var container: Container?

    public init(container: Container?) {
        self.container = container
    }

    func instantiateModule() -> DetailViewController {
        guard let controller = container?.resolve(DetailViewController.self) else {
            fatalError()
        }
        return controller
    }
}
