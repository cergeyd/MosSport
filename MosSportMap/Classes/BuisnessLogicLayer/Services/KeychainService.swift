//
//  KeychainService.swift
//  MosSportMap
//
//  Created by sergiusX on 15/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import KeychainAccess

class KeychainService {
    
    struct Config {
        static let tokenKey = "token"
    }

    private let keychain: Keychain!

    init(keychain: Keychain) {
        self.keychain = keychain
    }

    var bearerToken: String? {
        get {
            return self.keychain[Config.tokenKey]
        }
        set {
            self.keychain[Config.tokenKey] = newValue
        }
    }
    
    func clear() {
        self.bearerToken = nil
    }
}
