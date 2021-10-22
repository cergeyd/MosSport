//
//  ApplicationAssembly.swift
//  MosSportMap
//
//  Created by sergiusX on 15/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import Swinject
import UIKit

let applicationAssembler = Assembler([
    ApplicationAssembly(),
    NetworkAssembly(),
    ManagersAssembly(),
    ServicesAssembly(),
    CoreLayerAssembly(),
    KeychainAssembly(),
    MapModule(),
    CalculatedModule(),
    DetailModule(),
    ListModule(),
    ListInitialModule(),
    RecommendationModule(),
    MenuModule()
    ])

class ApplicationAssembly: Assembly {

    private let rootViewControllerKey = "RootViewControllerKey"

    func assemble(container: Container) {
        container.register(AppDelegateAppearanceService.self) { r in
            AppDelegateAppearanceService()
        }
        container.register(AppDelegatePreloadService.self) { r in
            AppDelegatePreloadService(keychainService: r.resolve(KeychainService.self)!, mosDataProcessing: r.resolve(MosDataProcessing.self)!)
        }
        container.register(AppDelegateFirstLaunchService.self) { r in
            AppDelegateFirstLaunchService(keychainService: r.resolve(KeychainService.self)!, notifications: NotificationCenter.default)
        }
        container.register(AppDelegateUnauthorizedService.self) { r in
            AppDelegateUnauthorizedService(menuFactory: r.resolve(MenuFactory.self)!, mapFactory: r.resolve(MapFactory.self)!)
        }
    }
}
