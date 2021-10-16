//
//  APIClientError.swift
//  MosSportMap
//
//  Created by sergiusX on 15/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import Foundation

class APIClientError: LocalizedError {

    private let error: String

    init(error: String) {
        self.error = error
    }

    public var errorDescription: String? {
        return self.error
    }
}
