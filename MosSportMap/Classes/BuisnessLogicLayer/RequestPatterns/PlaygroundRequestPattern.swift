//
//  PlaygroundRequestPattern.swift
//  MosSportMap
//
//  Created by sergiusX on 15/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import Alamofire

enum PlaygroundRequestPattern: RequestPattern {

    struct Keys {
        static let route = "playground"
        static let cityID = "cityID"
        static let token = "token"
    }

    case create(playground: String)

    var path: String {
        switch self {
        case .create:
            return "\(Keys.route)"
        }
    }

    var method: HTTPMethod {
        return .get
    }
}
