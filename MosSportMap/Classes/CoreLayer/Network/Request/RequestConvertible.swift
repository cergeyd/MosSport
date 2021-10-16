//
//  RequestConvertible.swift
//  MosSportMap
//
//  Created by sergiusX on 15/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import Alamofire

class RequestConvertible: URLRequestConvertible {

    private let requestBuilderAuthTokenParameterKey = "Authorization"
    private let pattern: RequestPattern
    private let hostURL: String
    private let keychainService: KeychainService
    private let headersFactory: RequestHeadersFactory

    init(pattern: RequestPattern, hostURL: String, keychainService: KeychainService, headersFactory: RequestHeadersFactory) {
        self.pattern = pattern
        self.hostURL = hostURL
        self.keychainService = keychainService
        self.headersFactory = headersFactory
    }

    func asURLRequest() throws -> URLRequest {
        guard let url = URL(string: self.pattern.hostUrl) else {
            fatalError("invalidURL")
        }

        var urlRequest = URLRequest(url: url.appendingPathComponent(self.pattern.path))

        if let httpBody = self.pattern.httpBody {
            urlRequest = try self.pattern.encoding.encode(urlRequest, with: nil)
            urlRequest.httpBody = httpBody
        } else {
            urlRequest = try pattern.encoding.encode(urlRequest, with: self.pattern.parameters)
        }
        urlRequest.httpMethod = self.pattern.method.rawValue
        
        if (self.pattern.isAuthNeeded) {
            guard let token = self.keychainService.bearerToken else {
                NotificationCenter.default.post(name: Notification.Name.unauthorized, object: true, userInfo: nil)
                throw APIClientError(error: "token is nil for path: \(self.pattern.path)")
            }
            print(token)
            urlRequest.setValue(("Bearer \(token)"), forHTTPHeaderField: self.requestBuilderAuthTokenParameterKey)
        }

        var headers = self.headersFactory.headers
        if let customHeaders = self.pattern.httpHeaders {
            customHeaders.forEach { parameter in headers[parameter.key] = parameter.value }
        }

        for (key, value) in headers {
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        if let timeoutInterval = pattern.timeoutInterval {
            urlRequest.timeoutInterval = timeoutInterval
        }

        return urlRequest
    }
}
