//
//  ManagersAssembly.swift
//  MosSportMap
//
//  Created by sergiusX on 15/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import Swinject
import RxSwift

class ManagersAssembly: Assembly {

    func assemble(container: Container) {
        container.register(StorageManager.self) { r in
            StorageManager(fileManager: FileManager.default)
        }
    }
}
