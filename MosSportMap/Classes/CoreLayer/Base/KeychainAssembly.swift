//
//  KeychainAssembly.swift
//  MosSportMap
//
//  Created by sergiusX on 15/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import Swinject
import RxSwift
import KeychainAccess

class KeychainAssembly: Assembly {
    
    private let keychaineServiceKey = "playground.serjey.com.Keychain"
    
    func assemble(container: Container) {
        container.register(KeychainService.self) { r in
            KeychainService(keychain: r.resolve(Keychain.self)!)
            }.inObjectScope(.container)
        
        container.register(Keychain.self) { r in
            Keychain(service: self.keychaineServiceKey)
        }
    }
}
