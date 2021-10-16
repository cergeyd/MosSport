//
//  RequestFactory.swift
//  MosSportMap
//
//  Created by sergiusX on 15/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import Swinject
import Alamofire

class RequestFactory<Service: URLRequestConvertible>: RequestConvertibleFactory {

    private weak var container: Container?
    private let hostURL: String
    private let serviceType: Service.Type
    private let requestHeadersFactory: RequestHeadersFactory

    public init(container: Container?, hostURL: String, serviceType: Service.Type, requestHeadersFactory: RequestHeadersFactory) {
        self.container = container
        self.hostURL = hostURL
        self.serviceType = serviceType
        self.requestHeadersFactory = requestHeadersFactory
    }

    func request(with requestPattern: RequestPattern) -> URLRequestConvertible {
        guard let requestConvertible = container?.resolve(self.serviceType, arguments: requestPattern, self.hostURL, self.requestHeadersFactory) else {
            fatalError()
        }
        return requestConvertible
    }
}
