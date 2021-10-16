//
//  ThrowErrors.swift
//  MosSportMap
//
//  Created by sergiusX on 15/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import Foundation

enum ThrowErrors: LocalizedError {
    
    case serialization
    case stringToData
    
    public var errorDescription: String? {
        switch self {
        case .serialization:
            return "Ошибка сериализации"
        case .stringToData:
            return "Ошибка сериализации в данные"
        }
    }
}
