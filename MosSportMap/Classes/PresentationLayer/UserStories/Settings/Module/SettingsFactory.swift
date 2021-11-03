//
//  SettingsSettingsFactory.swift
//  MosSportMap
//
//  Created by Sergey D on 03/11/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import Swinject

class SettingsFactory {

    private weak var container: Container?

    public init(container: Container?) {
        self.container = container
    }

    func instantiateModule() -> SettingsViewController {
        guard let controller = container?.resolve(SettingsViewController.self) else {
            fatalError()
        }
        return controller
    }
}
