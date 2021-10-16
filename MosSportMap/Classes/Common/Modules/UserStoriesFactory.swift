//
//  UserStoriesFactory.swift
//  MosSportMap
//
//  Created by sergiusX on 15/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import UIKit

protocol UserStoriesFactory {
    func instantiateModule() -> UIViewController
    func instantiateModuleNavigation() -> UINavigationController
}

extension UserStoriesFactory {
    
    func instantiateModuleNavigation() -> UINavigationController {
        let viewController = self.instantiateModule()
        let navigationController = UINavigationController(rootViewController: viewController)
        return navigationController
    }
}
