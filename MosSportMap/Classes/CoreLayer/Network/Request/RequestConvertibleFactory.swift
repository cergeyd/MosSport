//
//  RequestConvertibleFactory.swift
//  MosSportMap
//
//  Created by sergiusX on 15/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import Alamofire

protocol RequestConvertibleFactory {
    func request(with requestPattern: RequestPattern) -> URLRequestConvertible
}
