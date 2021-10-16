//
//  ServicesAssembly.swift
//  MosSportMap
//
//  Created by sergiusX on 15/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import Swinject

class ServicesAssembly: Assembly {

    func assemble(container: Container) {
        container.register(RequestPatternFactory.self) { r in
            RequestPatternFactory()
        }
        container.register(LocaleJSONHelper.self) { r in
            LocaleJSONHelper()
        }
        container.register(LocalService.self) { r in
            LocalService(localeJSONHelper: r.resolve(LocaleJSONHelper.self)!)
        }
        container.register(MosDataProcessing.self) { r in
            MosDataProcessing(localService: r.resolve(LocalService.self)!)
        }
        container.register(PlaygroundService.self) { r in
            PlaygroundService(
                apiClient: r.resolve(APIClient.self, name: NetworkAssembly.networkClientAssemblyDefault)!,
                requestPatternFactory: r.resolve(RequestPatternFactory.self)!
            )
        }
    }
}
