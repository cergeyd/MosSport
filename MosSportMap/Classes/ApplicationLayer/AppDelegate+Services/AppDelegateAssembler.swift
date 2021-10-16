//
//  AppDelegateAssembler.swift
//  MosSportMap
//
//  Created by sergiusX on 15/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import Swinject

class AppDelegateAssembler {

    private let resolver = applicationAssembler.resolver

    func resolveDependencies(appDelegate: AppDelegate) {
        appDelegate.services = [
            self.resolver.resolve(AppDelegateAppearanceService.self)!,
            self.resolver.resolve(AppDelegateFirstLaunchService.self)!,
            self.resolver.resolve(AppDelegatePreloadService.self)!,
            self.resolver.resolve(AppDelegateUnauthorizedService.self)!
        ]
    }
}
