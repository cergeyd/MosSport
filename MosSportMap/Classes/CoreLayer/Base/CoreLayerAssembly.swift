//
//  CoreLayerAssembly.swift
//  MosSportMap
//
//  Created by sergiusX on 15/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import Swinject

class CoreLayerAssembly: Assembly {

    private let configHostURLParameterKey = "HostURL"
    private let configEnvironmentParameterKey = "Environment"
    private let configBundleNameParameterKey = "CFBundleName"
    private let configBundleVersionParameterKey = "CFBundleVersion"
    private let configBundleShortVersionParameterKey = "CFBundleShortVersionString"

    func assemble(container: Container) {
        container.register(Config.self) { r in
            Config(
                hostURL: hostUrl,
                version: Bundle.main.object(forInfoDictionaryKey: self.configBundleShortVersionParameterKey) as! String,
                buildNumber: Bundle.main.object(forInfoDictionaryKey: self.configBundleVersionParameterKey) as! String,
                applicationName: Bundle.main.object(forInfoDictionaryKey: self.configBundleNameParameterKey) as! String,
                environment: Bundle.main.object(forInfoDictionaryKey: self.configEnvironmentParameterKey) as! String
            )
        }
    }
}
