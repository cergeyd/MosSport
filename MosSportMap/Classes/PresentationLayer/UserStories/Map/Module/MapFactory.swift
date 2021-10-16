//
//  MapMapFactory.swift
//  MosSportMap
//
//  Created by sergiusX on 14/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import Swinject

class MapFactory {

    private weak var container: Container?

    public init(container: Container?) {
        self.container = container
    }

    func instantiateModule() -> MapViewController {
        guard let controller = container?.resolve(MapViewController.self) else {
            fatalError()
        }
        return controller
    }
}
