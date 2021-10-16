//
//  MultipartRequestFactory.swift
//  MosSportMap
//
//  Created by sergiusX on 15/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import Alamofire

class MultipartRequestFactory {

    private let requestBuilderAuthTokenParameterKey = "Authorization"
    private let config: Config
    private let headersFactory: RequestHeadersFactory
    private let keychainService: KeychainService

    init(config: Config, headersFactory: RequestHeadersFactory, keychainService: KeychainService) {
        self.config = config
        self.headersFactory = headersFactory
        self.keychainService = keychainService
    }

    func url(with pattern: RequestPattern) -> URL {
        guard let url = URL(string: self.config.hostURL) else {
            fatalError("invalidURL")
        }
        return url.appendingPathComponent(pattern.path)
    }

    func headers(with pattern: RequestPattern) -> [String: String] {
        var headers = [String: String]()
        if pattern.isAuthNeeded {
            guard let token = self.keychainService.bearerToken else {
                fatalError("token is nil for path: \(pattern.path)")
            }
            headers[self.requestBuilderAuthTokenParameterKey] = "Bearer \(token)"
        }
        if let customHeaders = pattern.httpHeaders {
            customHeaders.forEach { parameter in headers[parameter.key] = parameter.value }
        }
        for (key, value) in headers {
            headers[key] = value
        }
        return headers
    }
}
