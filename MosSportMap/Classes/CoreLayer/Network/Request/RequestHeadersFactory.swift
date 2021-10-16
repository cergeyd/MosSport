//
//  RequestHeadersFactory.swift
//  MosSportMap
//
//  Created by sergiusX on 15/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import Foundation

private let defaultRequestContentTypeKey = "Content-Type"
private let defaultRequestPlatformKey = "platform"
private let defaultRequestEnvironmentKey = "environment"
private let defaultRequestAppVersionKey = "app-version"
private let defaultRequestBuildNumberKey = "build-number"

class RequestHeadersFactory {

    let headers: [String: String]

    init(config: Config) {
        self.headers =  [
            defaultRequestContentTypeKey: "application/json",
            defaultRequestPlatformKey: "iOS",
            defaultRequestAppVersionKey: config.version,
            defaultRequestBuildNumberKey: config.buildNumber,
            defaultRequestEnvironmentKey: config.environment
        ]
    }
}
