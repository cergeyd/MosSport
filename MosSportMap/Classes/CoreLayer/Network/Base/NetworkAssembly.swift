//
//  NetworkAssembly.swift
//  MosSportMap
//
//  Created by sergiusX on 15/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import Swinject
import Alamofire

class NetworkAssembly: Assembly {

    static let networkClientAssemblyDefault = "APIClientAssemblyDefault"

    private let networkAssemblyTimeoutInterval: TimeInterval = 12.0

    func assemble(container: Container) {
        //MARK: Default
        container.register(RequestConvertibleFactory.self, name: NetworkAssembly.networkClientAssemblyDefault) { r in
            let config = r.resolve(Config.self)!
            let headersFactory = RequestHeadersFactory(config: config)
            return RequestFactory<RequestConvertible>(container: container, hostURL: config.hostURL, serviceType: RequestConvertible.self, requestHeadersFactory: headersFactory)
        }
        container.register(RequestConvertible.self) { (r, pattern: RequestPattern, hostURL: String, headersFactory: RequestHeadersFactory) in
            return RequestConvertible(
                pattern: pattern,
                hostURL: hostURL,
                keychainService: r.resolve(KeychainService.self)!,
                headersFactory: headersFactory
            )
        }
        container.register(MultipartRequestFactory.self) { r in
            let config = r.resolve(Config.self)!
            let headersFactory = RequestHeadersFactory(config: config)
            return MultipartRequestFactory(config: config, headersFactory: headersFactory, keychainService: r.resolve(KeychainService.self)!)
        }
        container.register(APIClient.self, name: NetworkAssembly.networkClientAssemblyDefault) { r in
            let apiClient = APIClientDefault(
                sessionManager: r.resolve(Alamofire.Session.self)!,
                requestConvertibleFactory: r.resolve(RequestConvertibleFactory.self, name: NetworkAssembly.networkClientAssemblyDefault)!,
                multipartRequestFactory: r.resolve(MultipartRequestFactory.self)!, notifications: NotificationCenter.default
            )
            return apiClient
        }
        //MARK: SessionManager
        container.register(Alamofire.Session.self) { r in
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = self.networkAssemblyTimeoutInterval
            return Session(configuration: configuration)
        }
    }
}
